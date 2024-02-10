class Api::V1::StatusesController < ApplicationController
  before_action :authenticate_devise_api_token!

  def index
    @statuses = Status.all
    render json: @statuses
  end
end
