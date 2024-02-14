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
    if @payment.save
      procedure = Procedure.find(payment_params[:procedure_id])
      if procedure.cost_pending.positive?
        new_cost_pending = [0, procedure.cost_pending - @payment.value].max
        procedure.update(cost_pending: new_cost_pending)
      else
        procedure.update(profit_pending: 0)
      end
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

  # DELETE /api/v1/payments/:id
  def destroy
    @payment.destroy
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
