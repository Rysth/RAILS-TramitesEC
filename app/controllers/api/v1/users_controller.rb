class Api::V1::UsersController < ApplicationController
  before_action :authenticate_devise_api_token!

  def index
    @users = User.all
    render json: @users, status: :ok
  end

  def show
    @user = current_devise_api_user
    render json: @user, status: :ok
  end
end
