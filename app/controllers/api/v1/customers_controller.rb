class Api::V1::CustomersController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_customer, only: %i[show update destroy]

  def index
    render_customers_response
  end

  def show
    page = params[:page].to_i || 1
    per_page = 10
  
    procedures = @customer.procedures.includes(:status, :procedure_type, :user)
                  .order(created_at: :desc).page(page).per(per_page)
    completed_procedures = procedures.where(status_id: 4, is_paid: true)
    total_valores = completed_procedures.sum(:cost)
    total_ganancias = completed_procedures.sum(:profit)
    total_tramites = procedures.count
    total_tramites_finalizados = completed_procedures.count
  
    total_pages = procedures.total_pages
  
    customer_data = {
      first_name: @customer.first_name,
      last_name: @customer.last_name
    }
  
    # Include processor information only if the customer is not direct and has a processor
    processor_data = if !@customer.is_direct? && @customer.processor.present?
                       {
                         id: @customer.processor.id,
                         first_name: @customer.processor.first_name,
                         last_name: @customer.processor.last_name
                       }
                     else
                       nil
                     end
  
    render json: {
      procedures: procedures.as_json(include: { 
        customer: { only: [:id, :first_name, :last_name] },
        status: { only: [:id, :name] },
        procedure_type: { only: :name },
        processor: processor_data,
        user: { only: [:username] }
      }),
      customer: customer_data,
      customer_stats: {
        valores: total_valores,
        ganancias: total_ganancias,
        tramites: total_tramites,
        tramites_finalizados: total_tramites_finalizados,
      },
      pagination: {
        total_pages: total_pages,
        current_page: page
      }
    }, status: :ok
  end
  

  def create
    @customer = Customer.new(customer_params)
    @customer.user_id = current_devise_api_user.id

    if @customer.save!
      render json: customer_data(@customer), status: :created
    else
      render json: @customer.errors, status: :unprocessable_entity
    end
  end

  def update
    # Check if the customer is direct
    is_direct = params.dig(:customer, :is_direct)

    # If the customer is direct, remove the processor_id from the params
    if is_direct
      customer_params.delete(:processor_id)
    end

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

  def search_from_procedures
    query = params[:query]
    customers = Customer.where('LOWER(identification) LIKE :query', query: "%#{query}%").order(created_at: :desc).page(1)
    render json: customers.as_json(only: %i[id identification first_name last_name])
  end

  private

  def render_customers_response
    customers = all_customers
    render json: {
      customers: customers.as_json(include: { processor: { only: %i[id code first_name last_name phone] }, user: { only: %i[id username] } }),
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
      customers = customers.where('LOWER(identification) LIKE :search OR LOWER(CONCAT(first_name, \' \', last_name)) LIKE :search', search: search_term)
    end

    customers = customers.where(user_id: params[:userId]) if params[:userId].present?
    customers.page(params[:page]).per(20)
  end

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_data(customer)
    customer.as_json(
      include: {
        processor: { only: %i[id code first_name last_name] },
        user: { only: %i[id username] }
      }
    )
  end

  def customer_params
    params.require(:customer).permit(:id, :identification, :first_name, :last_name, :phone, :address, :email, :active, :processor_id, :is_direct)
  end
end
