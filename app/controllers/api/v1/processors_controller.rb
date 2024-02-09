class Api::V1::ProcessorsController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_processor, only: %i[show update destroy]

  def index
    render_processors_response
  end

  def show
    page = params[:page].to_i || 1
    per_page = 10
  
    procedures = @processor.procedures.includes(:customer, :status, :type, :user)
                  .order(created_at: :desc).page(page).per(per_page)
    completed_procedures = @processor.procedures.where(status_id: 3, valor_pendiente: 0, ganancia_pendiente: 0)
    total_valores = completed_procedures.sum(:valor)
    total_ganancias = completed_procedures.sum(:ganancia)
    total_clientes = @processor.customers.count
    total_tramites = @processor.procedures.count
  
    total_pages = procedures.total_pages
  
    render json: {
      procedures: procedures.as_json(include: { 
        customer: { only: [:nombres, :apellidos] },
        status: { only: [:id, :nombre] },
        type: { only: :nombre },
        processor: { only: [:nombres, :apellidos] },
        user: { only: [:username] }
      }),
      processor: @processor.as_json(only: [:nombres, :apellidos]),
      processor_stats: {
        valores: total_valores,
        ganancias: total_ganancias,
        clientes: total_clientes,
        tramites: total_tramites,
      },
      pagination: {
        total_pages: total_pages,
        current_page: page
      }
    }, status: :ok
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
