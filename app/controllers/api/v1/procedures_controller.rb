class Api::V1::ProceduresController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_procedure, only: %i[show update destroy]

  def index
    render_procedures_response
  end

  def show
    render json: procedure_data(@procedure), status: :ok
  end

  def create
    @procedure = Procedure.new(procedure_params)
    @procedure.user_id = current_devise_api_user.id

    if @procedure.save!
      render json: procedure_data(@procedure), status: :created
    else
      render json: @procedure.errors, status: :unprocessable_entity
    end
  end

  def update
    if @procedure.update(procedure_params)
      render json: procedure_data(@procedure), status: :ok
    else
      render json: @procedure.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @procedure.destroy
      render json: { message: 'Procedure successfully deleted.' }, status: :ok
    else
      render json: @procedure.errors, status: :unprocessable_entity
    end
  end

  def generate_excel
    # Extract start_date and end_date from params
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : nil

    # Query procedures within the specified date range and order by created_at in ascending order
    procedures = Procedure.includes(%i[user customer processor procedure_type status supplier agency])

    # Apply date range filtering if dates are provided
    procedures = procedures.where(created_at: start_date.beginning_of_day..end_date.end_of_day) if start_date && end_date

    # Order procedures by created_at in ascending order
    procedures = procedures.order(created_at: :asc)

    # Generate Excel file using axlsx_rails gem
    package = Axlsx::Package.new
    workbook = package.workbook
    workbook.add_worksheet(name: 'Procedures') do |sheet|
      # Add headers with new agency column
      header_rows = ['ID', 'Fecha de Creación', 'Código del Trámite', 'Agencia', 'Tipo de Trámite', 'Trámite', 'Usuario', 'Trámitador', 'Cliente', 'Placa',
                     'Estado del Trámite', 'Estado del Pago', 'Valor', 'Valor Abonado', 'Valor Pendiente', 'Ganancia', 'Ganancia Pendiente', 'Proveedor', 'Valor a Proveedor', 'Comentarios']
      sheet.add_row header_rows

      # Add data for each procedure
      procedures.each do |procedure|
        user_info = procedure.user.present? ? procedure.user.username.to_s : 'N/A'
        customer_info = procedure.customer.present? ? "#{procedure.customer.first_name} #{procedure.customer.last_name}" : 'N/A'
        procedure_type_info = procedure.procedure_type.present? ? procedure.procedure_type.name.to_s : 'N/A'
        procedure_has_licenses = procedure.procedure_type.present? && procedure.procedure_type.has_licenses ? 'Licencias' : 'Vehícular'
        processor_info = procedure.processor.present? ? "#{procedure.processor.first_name} #{procedure.processor.last_name}" : 'Cliente Directo'
        procedure_is_paid = procedure.is_paid ? 'Pagado' : 'Pendiente'
        status_info = procedure.status.present? ? procedure.status.name.to_s : 'N/A'
        supplier_info = procedure.supplier.present? ? procedure.supplier.name.to_s : 'N/A'
        agency_info = procedure.agency.present? ? procedure.agency.name.to_s : 'N/A'
        payments_amount = procedure.payments.sum(:value)

        body_rows = [procedure.id, procedure.created_at, procedure.code, agency_info, procedure_has_licenses, procedure_type_info, user_info, processor_info,
                     customer_info, procedure.plate, status_info, procedure_is_paid, procedure.cost, payments_amount, procedure.cost_pending, procedure.profit, procedure.profit_pending, supplier_info, procedure.supplier_amount, procedure.comments]
        sheet.add_row body_rows
      end

      # Calculate totals
      total_cost = procedures.sum(:cost)
      total_cost_pending = procedures.sum(:cost_pending)
      total_profit = procedures.sum(:profit)
      total_profit_pending = procedures.sum(:profit_pending)
      total_supplier_amount = procedures.sum(:supplier_amount)
      total_payments = procedures.joins(:payments).sum('payments.value')

      # Add totals row with correct order
      totals_row = [
        'Totales', '', '', '', '', '', '', '', '', '', '', '',
        total_cost, # Valor
        total_payments, # Valor Abonado
        total_cost_pending, # Valor Pendiente
        total_profit, # Ganancia
        total_profit_pending, # Ganancia Pendiente
        '', # Proveedor
        total_supplier_amount, # Valor a Proveedor
        '' # Comentarios
      ]
      sheet.add_row totals_row
    end

    # Set the content type for the response and send the file
    send_data package.to_stream.read, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', filename: 'procedures.xlsx'
  end

  private

  def render_procedures_response
    procedures = all_procedures
    render json: {
      procedures: procedures.map { |procedure| procedure_data(procedure) },
      pagination: {
        total_pages: procedures.total_pages,
        current_page: procedures.current_page,
        next_page: procedures.next_page,
        prev_page: procedures.prev_page,
        total_count: procedures.total_count
      }
    }, status: :ok
  end

  def procedure_data(procedure)
    procedure.as_json(
      include: {
        user: { only: %i[id username] },
        customer: { only: %i[id identification first_name last_name is_direct phone] },
        processor: { only: %i[id code first_name last_name phone] },
        procedure_type: { only: %i[id name has_licenses] },
        supplier: { only: %i[id identification name] },
        license: { only: %i[id name] },
        status: { only: %i[id name] },
        agency: { only: %i[id code name has_licenses] }
      }
    )
  end

  def all_procedures
    puts "\n=== Debug Search Query ==="
    puts "Search params: #{params[:search]}"
    puts "hasLicenses param: #{params[:hasLicenses]}"

    procedures = Procedure
      .includes(:user, :customer, :processor, :procedure_type, :license, :status, :supplier, :agency)
      .joins(:procedure_type)
      .left_joins(:customer) # Changed to left_joins for optional customers
      .order(id: :desc)

    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      puts "Search term: #{search_term}"

      procedures = procedures.where(
        'LOWER(procedures.code) LIKE :search OR ' \
        'LOWER(procedures.plate) LIKE :search OR ' \
        'LOWER(COALESCE(customers.identification, \'\')) LIKE :search OR ' \
        'LOWER(COALESCE(customers.first_name, \'\')) LIKE :search OR ' \
        'LOWER(COALESCE(customers.last_name, \'\')) LIKE :search',
        search: search_term
      )
    end

    if params[:hasLicenses].present?
      has_licenses = ActiveRecord::Type::Boolean.new.cast(params[:hasLicenses])
      puts "Has licenses value: #{has_licenses}"
      procedures = if has_licenses
                     procedures.where(procedure_types: { has_licenses: true })
                       .where.not(customers: { id: nil })
                   else
                     procedures.where(procedure_types: { has_licenses: false })
                   end
    end

    # Processor filter
    if params[:processorId].present?
      procedures = if params[:processorId].to_i.zero?
                     procedures.joins(:customer).where(customers: { is_direct: true })
                   else
                     procedures.where(processor_id: params[:processorId])
                   end
    end

    # Status filter
    procedures = procedures.where(status_id: params[:statusId]) if params[:statusId].present?

    # Independent Date Range Filters
    if params[:startDate].present?
      start_date = params[:startDate].to_date.beginning_of_day
      procedures = procedures.where('procedures.created_at >= ?', start_date)
    end

    if params[:endDate].present?
      end_date = params[:endDate].to_date.end_of_day
      procedures = procedures.where('procedures.created_at <= ?', end_date)
    end

    # Fix Selected Year filter with explicit table reference
    if params[:selectedYear].present?
      year = params[:selectedYear].to_i
      procedures = procedures.where('EXTRACT(YEAR FROM procedures.created_at) = ?', year)
    end

    # ShowUnpaid filter
    procedures = procedures.where(is_paid: false) if params[:showUnpaid].present?
    
    # Primera Vez filter - add this section
    if params[:showPrimeraVez].present?
      primera_vez_type = ProcedureType.find_by(name: 'Primera Vez')
      procedures = procedures.where(procedure_type_id: primera_vez_type.id) if primera_vez_type
    end

    puts "Final SQL Test: #{procedures.to_sql}"
    puts "Result count: #{procedures.count}"
    puts "=== End Debug ===\n"

    procedures.page(params[:page]).per(15)
  end

  def procedure_params
    params.require(:procedure).permit(
      :id, :plate, :cost, :cost_pending, :profit, :profit_pending,
      :comments, :procedure_type_id, :processor_id, :customer_id,
      :license_id, :supplier_amount, :supplier_id, :status_id,
      :created_at, :agency_id, :code, :date, :is_paid, :active,
      :user_id, :updated_at
    )
  end

  def set_procedure
    @procedure = Procedure.find(params[:id])
  end
end
