class Api::V1::CustomersController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_customer, only: %i[show update destroy]

  def index
    render_customers_response
  end

  def show
    page = params[:page].to_i || 1
    per_page = 10

    # Check if total values are already calculated
    calculate_total_values if @total_valores.nil? || @total_ganancias.nil? || @total_tramites.nil? || @total_tramites_finalizados.nil?

    procedures = @customer.procedures.includes(:status, :procedure_type, :user, :processor)
      .order(created_at: :desc)
      .page(page)
      .per(per_page)

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
                     end

    render json: {
      procedures: procedures.as_json(include: {
                                       customer: { only: %i[id first_name last_name] },
                                       status: { only: %i[id name] },
                                       procedure_type: { only: :name },
                                       processor: processor_data,
                                       user: { only: [:username] }
                                     }),
      customer: customer_data,
      customer_stats: {
        valores: @total_valores,
        ganancias: @total_ganancias,
        tramites: @total_tramites,
        tramites_finalizados: @total_tramites_finalizados,
        tramites_proceso: @total_tramites_proceso,
        tramites_pendientes: @total_tramites_pendientes
      },
      pagination: {
        total_pages:,
        current_page: page
      }
    }, status: :ok
  end

  def create
    @customer = Customer.new(customer_params)

    unless customer_params[:is_direct]
      @processor = Processor.select(:phone).find(customer_params[:processor_id])
      @customer.phone = @processor.phone
    end

    @customer.user_id = current_devise_api_user.id

    if @customer.save
      render json: customer_data(@customer), status: :created
    else
      render json: @customer.errors, status: :unprocessable_entity
    end
  end

  def update
    # Check if the customer is direct
    is_direct = params.dig(:customer, :is_direct)

    # If the customer is direct, remove the processor_id from the params
    customer_params.delete(:processor_id) if is_direct

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
    query = "%#{params[:query].downcase}%"
      raw_query = params[:query].to_s.strip.downcase

      customers = Customer.left_outer_joins(:procedures)
                           .order(created_at: :desc)

      if raw_query.present?
        like_query = "%#{raw_query}%"
        customers = customers.where(
          'LOWER(customers.identification) LIKE :q OR LOWER(customers.email) LIKE :q OR LOWER(CONCAT(customers.first_name, \' \' , customers.last_name)) LIKE :q OR LOWER(procedures.code) LIKE :q',
          q: like_query
        )
      end

      if params.key?(:processorId) && params[:processorId].present?
        customers = customers.where(processor_id: params[:processorId])
      end

      customers = customers.distinct.limit(20)

      render json: customers.as_json(only: %i[id identification first_name last_name email phone is_direct])
  end

  def generate_excel
    # Extract start_date and end_date from params
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : nil

    # Query customers within the specified date range and order by created_at in ascending order
    customers = Customer.includes(:procedures, :processor)

    # Apply date range filtering if dates are provided
    customers = customers.where(created_at: start_date.beginning_of_day..end_date.end_of_day) if start_date && end_date

    # Order customers by created_at in ascending order
    customers = customers.order(created_at: :asc)

    # Generate Excel file using axlsx_rails gem
    package = Axlsx::Package.new
    workbook = package.workbook
    workbook.add_worksheet(name: 'Clientes') do |sheet|
      # Add headers
      header_rows = ['ID', 'Trámitador', 'Identificación', 'Nombres', 'Apellidos', 'Teléfono', 'Dirección', 'Correo Electrónico',
                     'Fecha de Creación', 'Total de Trámites', 'Total de Valores', 'Total de Ganancias']
      sheet.add_row header_rows

      # Add data for each customer
      total_tramites_all = 0
      total_values_all = 0
      total_ganancias_all = 0

      customers.each do |customer|
        processor_info = customer.processor.present? ? "#{customer.processor.first_name} #{customer.processor.last_name}" : 'Cliente Directo'
        total_tramites = customer.procedures_count # Assuming procedures_count is a method returning the count of associated procedures
        total_values = customer.procedures.sum(&:cost) # Assuming total_values is a method returning the sum of total values
        total_ganancias = customer.procedures.sum(&:profit) # Assuming total_ganancias is a method returning the sum of total profits

        total_tramites_all += total_tramites
        total_values_all += total_values
        total_ganancias_all += total_ganancias

        body_rows = [customer.id, processor_info, customer.identification, customer.first_name, customer.last_name, customer.phone, customer.address,
                     customer.email, customer.created_at, total_tramites, total_values, total_ganancias]
        sheet.add_row body_rows
      end

      # Add totals row
      totals_row = ['Totales', '', '', '', '', '', '', '', '', total_tramites_all, total_values_all, total_ganancias_all]
      sheet.add_row totals_row
    end

    # Set the content type for the response and send the file
    send_data package.to_stream.read, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', filename: 'clientes.xlsx'
  end

  private

  def calculate_total_values
    completed_procedure_ids = @customer.procedures.where(status_id: 4, is_paid: true).pluck(:id)
    @total_valores = Procedure.where(id: completed_procedure_ids).sum(:cost)
    @total_ganancias = Procedure.where(id: completed_procedure_ids).sum(:profit)
    @total_tramites = @customer.procedures.count
    @total_tramites_proceso = @customer.procedures.where(status_id: [1, 3]).count
    @total_tramites_pendientes = @customer.procedures.where(is_paid: false).count
    @total_tramites_finalizados = completed_procedure_ids.count
  end

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
      customers = customers.where('LOWER(identification) LIKE :search OR LOWER(CONCAT(first_name, \' \', last_name)) LIKE :search',
                                  search: search_term)
    end

    customers = customers.where(user_id: params[:userId]) if params[:userId].present? # Filter by User

    if params[:processorId].present?
      customers = if params[:processorId].to_i.zero?
                    customers.where(is_direct: true) # Filter by Processor Id 0
                  else
                    customers.where(processor_id: params[:processorId]) # Filter by Processor Id
                  end
    end

    if params[:startDate].present? && params[:endDate].present?
      start_date = (params[:startDate].to_date + 1.day).beginning_of_day
      end_date = (params[:endDate].to_date + 1.day).end_of_day
      customers = customers.where(created_at: start_date..end_date)
    elsif params[:startDate].present?
      customers = customers.where('created_at >= ?', params[:startDate])
    elsif params[:endDate].present?
      customers = customers.where('created_at <= ?', params[:endDate])
    end

    customers.page(params[:page]).per(15)
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
    params.require(:customer).permit(:id, :identification, :first_name, :last_name, :phone, :address, :email, :active, :processor_id,
                                     :is_direct).tap do |customer_params|
      customer_params[:first_name] = customer_params[:first_name].strip.upcase if customer_params[:first_name].present?
      customer_params[:last_name] = customer_params[:last_name].strip.upcase if customer_params[:last_name].present?
    end
  end
end
