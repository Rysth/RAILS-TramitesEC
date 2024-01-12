class Api::V1::CustomersController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_customer, only: %i[show update destroy]

  def index
    render_customers_response
  end

  def show
    render json: @customer
  end

  def create
    @customer = Customer.new(customer_params)

    if @customer.save
      render_customers_response
    else
      render json: @customer.errors, status: :unprocessable_entity
    end
  end

  def update
    if @customer.update(customer_params)
      render_customers_response
    else
      render json: @customer.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @customer.destroy
      render_customers_response
    else
      render json: @customer.errors, status: :unprocessable_entity
    end
  end

  private

  def render_customers_response
    render json: {
      customers: all_customers.as_json(include: { processor: { only: %i[id] },  user: { only: %i[id username] } })
    }, status: :ok
  end

  def all_customers
    Customer.includes(processor: [:user]).order(created_at: :asc)
  end

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:id, :cedula, :nombres, :apellidos, :celular, :direccion, :email, :active, :processor_id, :user_id)
  end
end
