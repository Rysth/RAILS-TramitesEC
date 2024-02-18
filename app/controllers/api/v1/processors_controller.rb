class Api::V1::ProcessorsController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_processor, only: %i[show update destroy]

  def index
    render_processors_response
  end

  def show
    page = params[:page].to_i || 1
    per_page = 10

    procedures = @processor.procedures.includes(:customer, :status, :procedure_type, :user)
      .order(created_at: :desc).page(page).per(per_page)
    completed_procedures = @processor.procedures.where(status_id: 4, is_paid: true)

    # Calculate total values only if they haven't been calculated before
    if @total_valores.nil? || @total_ganancias.nil? ||
       @total_clientes.nil? || @total_tramites.nil?
      calculate_total_values(completed_procedures)
    end

    total_pages = procedures.total_pages

    render json: {
      procedures: procedures.as_json(include: { 
                                       customer: { only: %i[id first_name last_name] },
                                       status: { only: %i[id name] },
                                       procedure_type: { only: :name },
                                       processor: { only: %i[first_name last_name] },
                                       user: { only: [:username] }
                                     }),
      processor: @processor.as_json(only: %i[first_name last_name]),
      processor_stats: {
        valores: @total_valores,
        ganancias: @total_ganancias,
        clientes: @total_clientes,
        tramites: @total_tramites,
        tramites_proceso: @total_tramites_proceso,
        tramites_proveedor: @total_tramites_proveedor,
        tramites_finalizados: @total_tramites_finalizados
      },
      pagination: {
        total_pages:,
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
    if customers? || procedures?
      render json: { error: 'Processor has associated customers or procedures and cannot be deleted.' }, status: :conflict
    elsif @processor.destroy
      render json: { message: 'Processor successfully deleted.' }, status: :ok
    else
      render json: @processor.errors, status: :unprocessable_entity
    end
  end

  def search_processors
    query = "%#{params[:query].downcase}%"
    processors = if query.blank?
                   Processor.order(created_at: :desc).page(1)
                 else
                   Processor.where('LOWER(code) LIKE :query OR LOWER(CONCAT(first_name, \' \', last_name)) LIKE :query', query: "%#{query}%").order(created_at: :desc).page(1)
                 end
    render json: processors.as_json(only: %i[id code first_name last_name])
  end

  def generate_excel
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : nil
  
    if start_date.nil? || end_date.nil?
      render json: { error: 'Invalid date parameters' }, status: :unprocessable_entity
      return
    end
  
    # Query processors within the specified date range
    processors = Processor.includes(:user).where(created_at: start_date.beginning_of_day..end_date.end_of_day)
  
    # Generate Excel file using axlsx_rails gem
    package = Axlsx::Package.new
    workbook = package.workbook
    workbook.add_worksheet(name: 'Trámitadores') do |sheet| 
      # Add headers
      sheet.add_row ['ID', 'Código', 'Nombres', 'Apellidos', 'Fecha de Creación', 'Total de Clientes', 'Total de Trámites', 'Total de Valores' , 'Total de Ganancias', 'Usuario']
  
      # Add data for each processor
    processors.each do |processor|
        # Calculate total values for the current processor
        total_clients = processor.customers.count
        total_procedures = processor.procedures.count
        total_cost = processor.procedures.sum(:cost)
        total_profit = processor.procedures.sum(:profit)

        sheet.add_row [
          processor.id, processor.code, processor.first_name, processor.last_name, processor.created_at,
          total_clients, total_procedures, total_cost, total_profit, processor.user.username
        ]
      end
    end
  
    # Set the content type for the response and send the file
    send_data package.to_stream.read, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', filename: "tramitadores#{start_date}_to_#{end_date}.xlsx"
  end

  private

  def calculate_total_values(completed_procedures)
    @total_valores = completed_procedures.sum(:cost)
    @total_ganancias = completed_procedures.sum(:profit)
    @total_clientes = @processor.customers.count
    @total_tramites = @processor.procedures.count
    @total_tramites_proceso = @processor.procedures.where(status_id: [1, 3]).count
    @total_tramites_proveedor = @processor.procedures.where(status_id: 2).count
    @total_tramites_finalizados = @processor.procedures.where(status_id: 4).count
  end

  def customers?
    @processor.customers.exists?
  end

  def procedures?
    @processor.procedures.exists?
  end

  def render_processors_response
    processors = all_processors
    render json: {
      processors: processors.as_json(
        only: %i[id code first_name last_name phone],
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
      processors = processors.where('LOWER(code) LIKE :search OR LOWER(CONCAT(first_name, \' \', last_name)) LIKE :search', search: search_term)
    end

    processors = processors.where(user_id: params[:userId]) if params[:userId].present?
    processors.page(params[:page]).per(15)
  end

  def set_processor
    @processor = Processor.find(params[:id])
  end

  def processor_data(processor)
    processor.as_json(
      only: %i[id code first_name last_name phone],
      include: {
        user: {
          only: %i[id username]
        }
      }
    )
  end

  def processor_params
    params.require(:processor).permit(:id, :code, :first_name, :last_name, :phone)
  end
end
