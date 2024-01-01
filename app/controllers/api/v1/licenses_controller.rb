class Api::V1::LicensesController < ApplicationController
  before_action :authenticate_devise_api_token!

  def index
    @licenses = License.includes(:type).all
    render json: @licenses, status: :ok
  end
end
