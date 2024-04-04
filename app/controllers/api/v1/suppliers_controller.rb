# app/controllers/api/v1/suppliers_controller.rb
class Api::V1::SuppliersController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_supplier, only: %i[show update destroy]

  def index
    render_suppliers_response
  end

  def show
    render json: @supplier, status: :ok
  end

  def create
    @supplier = Supplier.new(supplier_params)
    @supplier.user_id = current_devise_api_user.id

    if @supplier.save
      render json: @supplier, status: :created
    else
      render json: @supplier.errors, status: :unprocessable_entity
    end
  end

  def update
    if @supplier.update(supplier_params)
      render json: @supplier, status: :ok
    else
      render json: @supplier.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @supplier.destroy
      render json: { message: 'Supplier successfully deleted.' }, status: :ok
    else
      render json: @supplier.errors, status: :unprocessable_entity
    end
  end

  private

  def render_suppliers_response
    suppliers = all_suppliers
    render json: suppliers, status: :ok
  end

  def all_suppliers
    suppliers = Supplier.includes(:user).order(created_at: :desc)
    suppliers.page(params[:page]).per(15)
  end

  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(:identification, :name, :phone, :email)
  end
end
