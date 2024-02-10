class Api::V1::LicenseTypesController < ApplicationController
  before_action :authenticate_devise_api_token!

  def index
    @license_types = LicenseType.all
    render json: @license_types
  end
end
