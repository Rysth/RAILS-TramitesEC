class Api::V1::CustomersController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_customer, only: %i[show update destroy]

  def index
    render_customers_response
  end

  def show
    render json: customer_data(@customer), status: :ok
  end

  def create
    @customer = Customer.new(customer_params)
    @customer.user_id = current_devise_api_user.id

    if @customer.save
      render json: customer_data(@customer), status: :created
    else
      render json: @customer.errors, status: :unprocessable_entity
    end
  end

  def update
    if @customer.update(customer_params)
      render json: customer_data(@customer), status: :ok
    else
      render json: @customer.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @customer.destroy
      render json: { message: 'Customer successfully deleted.' }, status: :ok
    else
      render json: @customer.errors, status: :unprocessable_entity
    end
  end

  private

  def render_customers_response
    customers = all_customers
    render json: {
      customers: customers.as_json(include: { processor: { only: %i[id] }, user: { only: %i[id username] } }),
      pagination: {
        total_pages: customers.total_pages,
        current_page: customers.current_page,
        next_page: customers.next_page,
        prev_page: customers.prev_page,
        total_count: customers.total_count
      }
    }, status: :ok
  end

  def all_customers
    customers = Customer.includes(:processor, :user).order(created_at: :desc)
  
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      customers = customers.where('LOWER(cedula) LIKE :search OR LOWER(email) LIKE :search OR LOWER(CONCAT(nombres, \' \', apellidos)) LIKE :search', search: search_term)
    end
  
    customers = customers.where(user_id: params[:userId]) if params[:userId].present?
    customers.page(params[:page])
  end
  

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_data(customer)
    customer.as_json(
      include: {
        processor: { only: %i[id] },
        user: { only: %i[id username] }
      }
    )
  end

  def customer_params
    params.require(:customer).permit(:id, :cedula, :nombres, :apellidos, :celular, :direccion, :email, :active, :processor_id)
  end
end
