class Api::V1::ProcedureSubTypesController < ApplicationController
  before_action :authenticate_devise_api_token!

  def index
    @procedure_sub_types = ProcedureSubType.all
    render json: @procedure_sub_types
  end
end
