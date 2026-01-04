class Api::V1::UsersController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :require_admin!, except: %i[index show]
  before_action :set_user, only: %i[update destroy update_password]

  def index
    render_users_response
  end

  def show
    @user = current_devise_api_user
    render json: {
      id: @user.id,
      username: @user.username,
      is_admin: @user.is_admin
    }, status: :ok
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render json: user_json(@user), status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    update_params = user_params.except(:password, :password_confirmation)
    
    if @user.update(update_params)
      render json: user_json(@user), status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    # Prevent deleting the current user
    if @user.id == current_devise_api_user.id
      render json: { error: 'No puedes eliminar tu propia cuenta.' }, status: :forbidden
      return
    end

    # Check for associated records
    if @user.processors.exists? || @user.procedures.exists? || @user.customers.exists? || @user.suppliers.exists?
      render json: { error: 'El usuario tiene registros asociados y no puede ser eliminado.' }, status: :conflict
    elsif @user.destroy
      render json: { message: 'Usuario eliminado exitosamente.' }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_password
    if params[:password].blank?
      render json: { errors: ['La contraseña no puede estar vacía.'] }, status: :unprocessable_entity
      return
    end

    if @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      render json: { message: 'Contraseña actualizada exitosamente.' }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def require_admin!
    unless current_devise_api_user.is_admin
      render json: { error: 'No tienes permisos para realizar esta acción.' }, status: :forbidden
    end
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :is_admin, :active, :notification_email)
  end

  def user_json(user)
    user.as_json(only: %i[id username email is_admin active notification_email created_at updated_at])
  end

  def render_users_response
    users = filtered_users

    if params[:full] == 'true'
      render json: users.map { |u| user_json(u) }, status: :ok
    else
      render json: {
        users: users.map { |u| user_json(u) },
        pagination: {
          total_pages: users.total_pages,
          current_page: users.current_page,
          next_page: users.next_page,
          prev_page: users.prev_page,
          total_count: users.total_count
        }
      }, status: :ok
    end
  end

  def filtered_users
    users = User.order(created_at: :desc)

    users = users.where(active: true) if ActiveModel::Type::Boolean.new.cast(params[:active_only])

    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      users = users.where('LOWER(username) LIKE ? OR LOWER(email) LIKE ?', search_term, search_term)
    end

    start_date_param = params[:start_date] || params[:startDate]
    end_date_param = params[:end_date] || params[:endDate]

    if start_date_param.present?
      start_date = start_date_param.to_date.beginning_of_day
      users = users.where('created_at >= ?', start_date)
    end

    if end_date_param.present?
      end_date = end_date_param.to_date.end_of_day
      users = users.where('created_at <= ?', end_date)
    end

    return users if params[:full] == 'true'

    users.page(params[:page]).per(15)
  end
end
