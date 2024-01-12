class Api::V1::ProcessorsController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_processor, only: %i[show update destroy]

  def index
    render_processors_response
  end

  # Extract this method for Profile
  def show
    render_processors_response
  end

  def create
    @processor = Processor.new(processor_params)

    if @processor.save
      render_processors_response
    else
      render json: @processor.errors, status: :unprocessable_entity
    end
  end

  def update
    if @processor.update(processor_params)
      render_processors_response
    else
      render json: @processor.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if customers?
      return render json: {
        processors: all_processors.map do |processor|
          {
            id: processor.id,
            codigo: processor.codigo,
            nombres: processor.nombres,
            apellidos: processor.apellidos,
            celular: processor.celular,
            user: {
              id: processor.user&.id,
              username: processor.user&.username
            }
          }
        end
      }.to_json, status: :conflict
    end

    if @processor.destroy
      render_processors_response
    else
      render json: @processor.errors, status: :unprocessable_entity
    end
  end

  private

  def customers?
    @processor.customers.exists?
  end

  def render_processors_response
    render json: {
      processors: all_processors.map do |processor|
        {
          id: processor.id,
          codigo: processor.codigo,
          nombres: processor.nombres,
          apellidos: processor.apellidos,
          celular: processor.celular,
          user: {
            id: processor.user&.id,
            username: processor.user&.username
          }
        }
      end
    }, status: :ok
  end

  def all_processors
    Processor.includes(:user).order(created_at: :asc)
  end

  def set_processor
    @processor = Processor.find(params[:id])
  end

  def processor_params
    params.require(:processor).permit(:cedula, :nombres, :apellidos, :celular, :active, :user_id)
  end
end
