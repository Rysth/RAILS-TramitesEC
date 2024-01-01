class Api::V1::TypesController < ApplicationController
  before_action :authenticate_devise_api_token!

  def index
    @types = Type.all
    render json: @types, status: :ok
  end
end
