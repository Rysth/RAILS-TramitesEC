class Api::V1::LicensesController < ApplicationController
  before_action :authenticate_devise_api_token!

  def index
    @licenses = License.includes(:type).all
    render json: @licenses.as_json(include: { type: { only: %i[id] } }), status: :ok
  end
end
