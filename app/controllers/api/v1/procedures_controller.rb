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
    procedures = Procedure.includes(%i[user customer processor procedure_type status supplier])
  
    # Apply date range filtering if dates are provided
    if start_date && end_date
      procedures = procedures.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end
  
    # Order procedures by created_at in ascending order
    procedures = procedures.order(created_at: :asc)
  
    # Generate Excel file using axlsx_rails gem
    package = Axlsx::Package.new
    workbook = package.workbook
    workbook.add_worksheet(name: 'Procedures') do |sheet|
      # Add headers
      header_rows = ['ID', 'Fecha de Creación', 'Código del Trámite', 'Tipo de Trámite', 'Trámite', 'Usuario', 'Trámitador', 'Cliente', 'Placa',
                     'Estado del Trámite', 'Estado del Pago', 'Valor', 'Valor Pendiente', 'Ganancia', 'Ganancia Pendiente', 'Proveedor', 'Valor a Proveedor', 'Comentarios']
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
        supplier_info = procedure.supplier.present? ? procedure.supplier.name.to_s : "N/A"
  
        body_rows = [procedure.id, procedure.created_at, procedure.code, procedure_has_licenses, procedure_type_info, user_info, processor_info,
                     customer_info, procedure.plate, status_info, procedure_is_paid, procedure.cost, procedure.cost_pending, procedure.profit, procedure.profit_pending, supplier_info, procedure.supplier_amount, procedure.comments]
        sheet.add_row body_rows
      end
  
      # Calculate totals
      total_cost = procedures.sum(:cost)
      total_cost_pending = procedures.sum(:cost_pending)
      total_profit = procedures.sum(:profit)
      total_profit_pending = procedures.sum(:profit_pending)
      total_supplier_amount = procedures.sum(:supplier_amount)
  
      # Add totals row
      totals_row = ['Totales', '', '', '', '', '', '', '', '', '', '', total_cost, total_cost_pending, total_profit, total_profit_pending, '',
                    total_supplier_amount, '']
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
        customer: { only: %i[id identification first_name last_name is_direct] },
        processor: { only: %i[id code first_name last_name] },
        procedure_type: { only: %i[id name has_licenses] },
        supplier: { only: %i[id identification name] },
        license: { only: %i[id name] },
        status: { only: %i[id name] },
      }
    )
  end

  def all_procedures
    procedures = Procedure.includes(:user, :customer, :processor, :procedure_type, :license, :status).order(id: :desc)
    
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      procedures = procedures.includes(:customer)
      procedures = procedures.where(
        'LOWER(procedures.code) LIKE :search OR ' \
        'LOWER(procedures.plate) LIKE :search OR ' \
        'LOWER(CONCAT(customers.first_name, \' \', customers.last_name)) LIKE :search',
        search: search_term
      )
    end

    procedures = procedures.where(user_id: params[:userId]) if params[:userId].present?
    
    if params[:processorId].present?
      if params[:processorId].to_i.zero?
        procedures = procedures.joins(:customer).where(customers: { is_direct: true }) # Filter by Processor Id 0
      else
        procedures = procedures.where(processor_id: params[:processorId]) # Filter by Processor Id
      end
    end

     # Filter procedures based on the presence of licenses
    if params[:hasLicenses].present?
      has_licenses = ActiveRecord::Type::Boolean.new.cast(params[:hasLicenses])
      procedures = has_licenses ? procedures.joins(:procedure_type).where(procedure_types: { has_licenses: true }) : procedures.joins(:procedure_type).where(procedure_types: { has_licenses: false })
    end

    procedures = procedures.where(status_id: params[:statusId]) if params[:statusId].present?
    procedures = procedures.where(procedure_type_id: params[:procedureTypeId]) if params[:procedureTypeId].present?

    if params[:startDate].present? && params[:endDate].present?
      start_date = (params[:startDate].to_date + 1.day).beginning_of_day
      end_date = (params[:endDate].to_date + 1.day).end_of_day
      procedures = procedures.where(created_at: start_date..end_date)
    elsif params[:startDate].present?
      procedures = procedures.where('created_at >= ?', params[:startDate])
    elsif params[:endDate].present?
      procedures = procedures.where('created_at <= ?', params[:endDate])
    end
  

    procedures.page(params[:page]).per(15)
  end

  def procedure_params
    params.require(:procedure).permit(:id, :plate, :cost, :cost_pending, :profit, :profit_pending, :comments, :procedure_type_id, :processor_id,
                                      :customer_id, :license_id, :supplier_amount, :supplier_id, :status_id, :created_at)
  end

  def set_procedure
    @procedure = Procedure.find(params[:id])
  end
end
