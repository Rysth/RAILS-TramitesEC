class Api::V1::ProcedureTypesController < ApplicationController
  before_action :authenticate_devise_api_token!

  def index
    @procedure_types = ProcedureType.all
    render json: @procedure_types
  end
end
