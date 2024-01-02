class Api::V1::LicensesController < ApplicationController
  before_action :authenticate_devise_api_token!

  def index
    @licenses = License.all
    render json: @licenses, status: :ok
  end
end
