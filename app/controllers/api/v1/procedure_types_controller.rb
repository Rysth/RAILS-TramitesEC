class Api::V1::ProcedureTypesController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_procedure_type, only: %i[show update destroy]

  def index
    render_procedure_types_response
  end

  def show
    render json: @procedure_type
  end

  def create
    @procedure_type = ProcedureType.new(procedure_type_params)

    if @procedure_type.save
      render json: @procedure_type, status: :created
    else
      render json: @procedure_type.errors, status: :unprocessable_entity
    end
  end

  def update
    if @procedure_type.update(procedure_type_params)
      render json: @procedure_type, status: :ok
    else
      render json: @procedure_type.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @procedure_type.destroy
      render json: { message: 'ProcedureType successfully deleted.' }, status: :ok
    else
      render json: @procedure_type.errors, status: :unprocessable_entity
    end
  end

  private

  def render_procedure_types_response
    procedure_types = all_procedure_types

    if params[:full] == 'true'
      render json: {
        procedure_types: procedure_types.as_json(
          only: %i[id name active has_licenses]
        )
      }, status: :ok
    else
      render json: {
        procedure_types: procedure_types.as_json(
          only: %i[id name active has_licenses]
        ),
        pagination: {
          total_pages: procedure_types.total_pages,
          current_page: procedure_types.current_page,
          next_page: procedure_types.next_page,
          prev_page: procedure_types.prev_page,
          total_count: procedure_types.total_count
        }
      }, status: :ok
    end
  end

  def all_procedure_types
    procedure_types = ProcedureType.order(created_at: :desc)

    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      procedure_types = procedure_types.where('LOWER(name) LIKE :search', search: search_term)
    end

    if params[:startDate].present? && params[:endDate].present?
      start_date = (params[:startDate].to_date + 1.day).beginning_of_day
      end_date = (params[:endDate].to_date + 1.day).end_of_day
      procedure_types = procedure_types.where(created_at: start_date..end_date)
    elsif params[:startDate].present?
      procedure_types = procedure_types.where('created_at >= ?', params[:startDate])
    elsif params[:endDate].present?
      procedure_types = procedure_types.where('created_at <= ?', params[:endDate])
    end

    procedure_types.page(params[:page]).per(15)
  end

  def set_procedure_type
    @procedure_type = ProcedureType.find(params[:id])
  end

  def procedure_type_params
    params.require(:procedure_type).permit(:name, :active, :has_licenses)
  end
end
