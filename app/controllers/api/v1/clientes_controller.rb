class Api::V1::ClientesController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_cliente, only: %i[show update destroy]

  def index
    render json: {
      customers: all_clientes,
      stats: calculate_statistics
    }, status: :ok
  end

  def show
    render json: @cliente
  end

  def create
    @cliente = Cliente.new(cliente_params)

    if @cliente.save
      render json: {
        customers: all_clientes,
        stats: calculate_statistics
      }, status: :ok
    else
      render json: @cliente.errors, status: :unprocessable_entity
    end
  end

  def update
    if @cliente.update(cliente_params)
      render json: {
        customers: all_clientes,
        stats: calculate_statistics
      }, status: :ok
    else
      render json: @cliente.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @cliente.destroy
      render json: {
        customers: all_clientes,
        stats: calculate_statistics
      }, status: :ok
    else
      render json: @cliente.errors, status: :unprocessable_entity
    end
  end

  private 

  def calculate_statistics
    customers_quantity = Cliente.count
    customers_active = Cliente.where(active: true).count
    customers_inactive = customers_quantity - customers_active

    {
      customers_quantity:,
      customers_active:,
      customers_inactive:
    }
  end

  def all_clientes
    Cliente.all.order(created_at: :asc)
  end

  def set_cliente
    @cliente = Cliente.find(params[:id])
  end

  def cliente_params
    params.require(:cliente).permit(:cedula, :nombres, :apellidos, :celular, :direccion, :email, :active, :user_id)
  end
end
