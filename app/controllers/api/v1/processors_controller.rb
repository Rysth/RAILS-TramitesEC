class Api::V1::ProcessorsController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_processor, only: %i[show update destroy]

  def index
    render_processors_response
  end

  def show
    render json: @processor
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
    return render json: @processor.errors, status: :conflict if customers?

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
      processors: all_processors,
      stats: calculate_statistics
    }, status: :ok
  end

  def calculate_statistics
    processors_quantity = Processor.count
    processors_active = Processor.where(active: true).count
    processors_inactive = processors_quantity - processors_active

    {
      processors_quantity:,
      processors_active:,
      processors_inactive:
    }
  end

  def all_processors
    Processor.all.order(created_at: :asc)
  end

  def set_processor
    @processor = Processor.find(params[:id])
  end

  def processor_params
    params.require(:processor).permit(:cedula, :nombres, :apellidos, :celular, :active, :user_id)
  end
end
