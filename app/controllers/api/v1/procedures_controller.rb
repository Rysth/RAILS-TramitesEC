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
        license: { only: %i[id name] },
        status: { only: %i[id name] }
      }
    )
  end

  def all_procedures
    procedures = Procedure.includes(:user, :customer, :processor, :procedure_type, :license, :status).order(created_at: :desc)
    
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      procedures = procedures.joins(:customer)
      procedures = procedures.where(
        'LOWER(procedures.code) LIKE :search OR ' \
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
    if params[:has_licenses].present?
      has_licenses = ActiveRecord::Type::Boolean.new.cast(params[:has_licenses])
      procedures = has_licenses ? procedures.joins(:procedure_type).where(procedure_types: { has_licenses: true }) : procedures.joins(:procedure_type).where(procedure_types: { has_licenses: false })
    end

    procedures = procedures.where(status_id: params[:statusId]) if params[:statusId].present?
    procedures = procedures.where(procedure_type_id: params[:procedureTypeId]) if params[:procedureTypeId].present?
    
    procedures.page(params[:page]).per(15)
  end

  def procedure_params
    params.require(:procedure).permit(:id, :plate, :cost, :cost_pending, :profit, :profit_pending, :comments, :procedure_type_id, :processor_id,
                                      :customer_id, :license_id, :status_id)
  end

  def set_procedure
    @procedure = Procedure.find(params[:id])
  end
end
