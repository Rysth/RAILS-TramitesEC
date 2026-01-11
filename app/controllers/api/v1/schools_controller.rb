class Api::V1::SchoolsController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_school, only: %i[show update destroy]

  def index
    render_schools_response
  end

  def show
    render json: @school.as_json(only: %i[id name active created_at]), status: :ok
  end

  def create
    @school = School.new(school_params)

    if @school.save
      render json: @school.as_json(only: %i[id name active created_at]), status: :created
    else
      render json: @school.errors, status: :unprocessable_entity
    end
  end

  def update
    if @school.update(school_params)
      render json: @school.as_json(only: %i[id name active created_at]), status: :ok
    else
      render json: @school.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @school.procedures.exists?
      render json: { error: 'School has associated procedures and cannot be deleted.' }, status: :conflict
    elsif @school.destroy
      render json: { message: 'School successfully deleted.' }, status: :ok
    else
      render json: @school.errors, status: :unprocessable_entity
    end
  end

  private

  def set_school
    @school = School.find(params[:id])
  end

  def school_params
    params.require(:school).permit(:name, :active)
  end

  def render_schools_response
    schools = filtered_schools

    if params[:full] == 'true'
      render json: schools.as_json(only: %i[id name active created_at]), status: :ok
    else
      render json: {
        schools: schools.as_json(only: %i[id name active created_at]),
        pagination: {
          total_pages: schools.total_pages,
          current_page: schools.current_page,
          next_page: schools.next_page,
          prev_page: schools.prev_page,
          total_count: schools.total_count
        }
      }, status: :ok
    end
  end

  def filtered_schools
    schools = School.order(created_at: :desc)

    schools = schools.active if ActiveModel::Type::Boolean.new.cast(params[:active_only])

    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      schools = schools.where('LOWER(name) LIKE ?', search_term)
    end

    start_date_param = params[:start_date] || params[:startDate]
    end_date_param = params[:end_date] || params[:endDate]

    if start_date_param.present?
      start_date = start_date_param.to_date.beginning_of_day
      schools = schools.where('created_at >= ?', start_date)
    end

    if end_date_param.present?
      end_date = end_date_param.to_date.end_of_day
      schools = schools.where('created_at <= ?', end_date)
    end

    return schools if params[:full] == 'true'

    schools.page(params[:page]).per(15)
  end
end
