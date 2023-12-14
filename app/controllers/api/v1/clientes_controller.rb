class Api::V1::ClientesController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_cliente, only: %i[show update destroy]

  def index
    @clientes = Cliente.all.order(created_at: :asc)
    render json: @clientes, status: :ok
  end

  def show
    render json: @cliente
  end

  def create
    @cliente = Cliente.new(cliente_params)

    if @cliente.save
      render json: @cliente, status: :created
    else
      render json: @cliente.errors, status: :unprocessable_entity
    end
  end

  def update
    if @cliente.update(cliente_params)
      render json: @cliente
    else
      render json: @cliente.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @cliente.destroy
    head :no_content
  end

  private 

  def set_cliente
    @cliente = Cliente.find(params[:id])
  end

  def cliente_params
    params.require(:cliente).permit(:cedula, :nombres, :apellidos, :celular, :direccion, :email, :active, :user_id)
  end
end
