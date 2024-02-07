class Api::V1::ProcessorsController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_processor, only: %i[show update destroy calculate_quantity_and_months]

  def index
    render_processors_response
  end

  def show
    render_processors_response
  end

  def create
    @processor = Processor.new(processor_params)
    @processor.user_id = current_devise_api_user.id

    if @processor.save
      render json: processor_data(@processor), status: :created
    else
      render json: @processor.errors, status: :unprocessable_entity
    end
  end

  def update
    if @processor.update(processor_params)
      render json: processor_data(@processor), status: :ok
    else
      render json: @processor.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if customers?
      render json: { error: 'Processor has associated customers and cannot be deleted.' }, status: :conflict
    elsif @processor.destroy
      render json: { message: 'Processor successfully deleted.' }, status: :ok
    else
      render json: @processor.errors, status: :unprocessable_entity
    end
  end

  def search_from_customers
    query = params[:query]
    processors = Processor.where('LOWER(codigo) LIKE :query OR LOWER(CONCAT(nombres, \' \', apellidos)) LIKE :query',
                                 query: "%#{query}%").order(created_at: :desc).page(1)
    render json: processors.as_json(only: %i[id codigo nombres apellidos])
  end

  
  def calculate_quantity_and_months
    quantity_and_months = []
  
    (0..3).reverse_each do |i|
      month_start = i.months.ago.beginning_of_month
      month_end = i.months.ago.end_of_month
  
      customers = Customer.where(processor_id: @processor.id)
                          .where(created_at: month_start..month_end)
      procedures = Procedure.where(processor_id: @processor.id)
                          .where(created_at: month_start..month_end)
  
      quantity_and_months << {
        Mes: month_start.strftime('%B %Y'),
        Clientes: customers.count,
        Tramites: procedures.count
      }
    end
  
    render json: quantity_and_months
  end
  

  private

  def customers?
    @processor.customers.exists?
  end

  def render_processors_response
    processors = all_processors
    render json: {
      processors: processors.as_json(
        only: %i[id codigo nombres apellidos celular],
        include: {
          user: {
            only: %i[id username]
          }
        }
      ),
      pagination: {
        total_pages: processors.total_pages,
        current_page: processors.current_page,
        next_page: processors.next_page,
        prev_page: processors.prev_page,
        total_count: processors.total_count
      }
    }, status: :ok
  end

  def all_processors
    processors = Processor.includes(:user).order(created_at: :desc)

    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      processors = processors.where('LOWER(codigo) LIKE :search OR LOWER(CONCAT(nombres, \' \', apellidos)) LIKE :search', search: search_term)
    end

    processors = processors.where(user_id: params[:userId]) if params[:userId].present?
    processors.page(params[:page]).per(20)
  end

  def set_processor
    @processor = Processor.find(params[:id])
  end

  def processor_data(processor)
    processor.as_json(
      only: %i[id codigo nombres apellidos celular],
      include: {
        user: {
          only: %i[id username]
        }
      }
    )
  end

  def processor_params
    params.require(:processor).permit(:nombres, :apellidos, :celular)
  end
end
