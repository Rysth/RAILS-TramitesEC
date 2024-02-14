class Api::V1::PaymentTypesController < ApplicationController
  before_action :authenticate_devise_api_token!

  def index
    @payment_types = PaymentType.select(:id, :name).all
    render json: @payment_types
  end

  # GET /api/v1/payment_types/:id
  def show
    @payment_type = PaymentType.find(params[:id])
    render json: @payment_type
  end
end
