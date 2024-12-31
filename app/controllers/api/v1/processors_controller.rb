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
                   Processor.where('LOWER(code) LIKE :query OR LOWER(CONCAT(first_name, \' \', last_name)) LIKE :query',
                                   query: "%#{query}%").order(created_at: :desc).page(1)
                 end
    render json: processors.as_json(only: %i[id code first_name last_name])
  end

  def generate_excel
    # Extract start_date and end_date from params
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : nil

    # Query processors within the specified date range and order by created_at in ascending order
    processors = Processor.includes(:user)

    # Apply date range filtering if dates are provided
    processors = processors.where(created_at: start_date.beginning_of_day..end_date.end_of_day) if start_date && end_date

    # Order processors by created_at in ascending order
    processors = processors.order(created_at: :asc)

    is_admin = params[:is_admin] == 'true' if params[:is_admin].present?

    # Generate Excel file using axlsx_rails gem
    package = Axlsx::Package.new
    workbook = package.workbook
    workbook.add_worksheet(name: 'Trámitadores') do |sheet|
      # Add headers
      header_rows = ['ID', 'Usuario', 'Código', 'Nombres', 'Apellidos', 'Teléfono', 'Fecha de Creación', 'Total de Clientes', 'Total de Trámites']
      header_rows.push('Total de Valores', 'Total de Ganancias') if is_admin
      sheet.add_row header_rows

      # Add data for each processor
      total_clients_all = 0
      total_procedures_all = 0
      total_cost_all = 0
      total_profit_all = 0

      processors.each do |processor|
        # Calculate total values for the current processor
        has_procedures = processor.procedures.count.positive?

        total_clients = processor.customers_count
        total_procedures = processor.procedures_count
        total_cost = processor.procedures.sum(:cost) if has_procedures
        total_profit = processor.procedures.sum(:profit) if has_procedures

        total_clients_all += total_clients
        total_procedures_all += total_procedures
        total_cost_all += total_cost if has_procedures
        total_profit_all += total_profit if has_procedures

        body_rows = [processor.id, processor.user.username, processor.code, processor.first_name, processor.last_name, processor.phone,
                     processor.created_at, total_clients, total_procedures]
        body_rows.push(total_cost, total_profit) if is_admin

        sheet.add_row body_rows
      end

      # Add totals row
      totals_row = ['Totales', '', '', '', '', '', '', total_clients_all, total_procedures_all]
      totals_row.push(total_cost_all, total_profit_all) if is_admin
      sheet.add_row totals_row
    end

    # Set the content type for the response and send the file
    send_data package.to_stream.read, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', filename: 'tramitadores.xlsx'
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
    if params[:startDate].present? && params[:endDate].present?
      start_date = (params[:startDate].to_date + 1.day).beginning_of_day
      end_date = (params[:endDate].to_date + 1.day).end_of_day
      processors = processors.where(created_at: start_date..end_date)
    elsif params[:startDate].present?
      processors = processors.where('created_at >= ?', params[:startDate])
    elsif params[:endDate].present?
      processors = processors.where('created_at <= ?', params[:endDate])
    end

    processors.each do |supplier|
      puts supplier.inspect
    end

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
    params.require(:processor).permit(:id, :code, :first_name, :last_name, :phone).tap do |processor_params|
      processor_params[:first_name] = processor_params[:first_name].strip.upcase if processor_params[:first_name].present?
      processor_params[:last_name] = processor_params[:last_name].strip.upcase if processor_params[:last_name].present?
    end
  end
end
