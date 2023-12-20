class Api::V1::UsersController < ApplicationController
  before_action :authenticate_devise_api_token!

  def show
    @user = current_devise_api_user
    render json: @user, status: :ok
  end
end