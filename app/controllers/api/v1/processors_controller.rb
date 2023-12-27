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
      processors: all_processors.map do |processor|
        {
          id: processor.id,
          cedula: processor.cedula,
          nombres: processor.nombres,
          apellidos: processor.apellidos,
          celular: processor.celular,
          user: {
            id: processor.user&.id,
            username: processor.user&.username
          }
        }
      end,
      stats: calculate_statistics
    }.to_json, status: :ok
  end

  def calculate_statistics
    processors_quantity = Processor.count
    processors_added_last_month = Processor.where('created_at >= ?', 1.month.ago).count
    processors_added_last_7_days = Processor.where('created_at >= ?', 7.days.ago).count

    {
      processors_quantity:,
      processors_added_last_month:,
      processors_added_last_7_days:
    }
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
