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

    if @procedure.save
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
        customer: { only: %i[id cedula nombres apellidos] },
        processor: { only: %i[id codigo nombres apellidos] },
        type: { only: %i[id nombre] },
        license: { only: %i[id nombre] },
        status: { only: %i[id nombre] }
      }
    )
  end

  
  def all_procedures
    procedures = Procedure.includes(:user, :customer, :processor, :type, :license, :status).order(created_at: :desc)

    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      procedures = procedures.joins(:processor, :status).where('LOWER(procedures.codigo) LIKE :search OR LOWER(CONCAT(processors.nombres, \' \', processors.apellidos)) LIKE :search OR LOWER(statuses.nombre) LIKE :search', search: search_term)
    end

    procedures = procedures.where(user_id: params[:userId]) if params[:userId].present?
    procedures.page(params[:page]).per(20)
  end

  def procedure_params
    params.require(:procedure).permit(:id, :placa, :valor, :valor_pendiente, :ganancia, :ganancia_pendiente, :observaciones, :type_id, :processor_id, :customer_id, :license_id, :status_id)
  end

  def set_procedure
    @procedure = Procedure.find(params[:id])
  end
end
