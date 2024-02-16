class Api::V1::PaymentsController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_payment, only: %i[update destroy]

  # GET /api/v1/payments
  def index
    @payments = Payment.all
    render json: @payments
  end

  # GET /api/v1/payments/:id
  def show
    @payments = Payment.includes(:payment_type).where(procedure_id: params[:id]).all
    render json: @payments, include: :payment_type
  end

  # POST /api/v1/payments
  def create
    @payment = Payment.new(payment_params)
    procedure = Procedure.find(payment_params[:procedure_id])

    # Check if both cost_pending and profit_pending are already zero
    if procedure.cost_pending.zero? && procedure.profit_pending.zero?
      render json: { error: 'Cannot create new payments when cost_pending and profit_pending are both zero' }, status: :unprocessable_entity
      return
    end

    if @payment.save
      new_cost_pending = [0, procedure.cost_pending - @payment.value].max
      procedure.update(cost_pending: new_cost_pending)

      # Check if the new cost_pending is zero and update profit_pending accordingly
      procedure.update(profit_pending: 0, is_paid: true) if new_cost_pending.zero?

      render json: @payment, status: :created
    else
      render json: @payment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/payments/:id
  def update
    if @payment.update(payment_params)
      render json: @payment
    else
      render json: @payment.errors, status: :unprocessable_entity
    end
  end

  def destroy
    procedure = @payment.procedure

    if @payment.destroy
      new_cost_pending = procedure.cost_pending + @payment.value
      procedure.update(cost_pending: new_cost_pending, is_paid: false, profit_pending: procedure.profit)
      head :no_content
    else
      render json: @payment.errors, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_payment
    @payment = Payment.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def payment_params
    params.require(:payment).permit(:value, :receipt_number, :payment_type_id, :procedure_id)
  end
end
