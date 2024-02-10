class Api::V1::UsersController < ApplicationController
  before_action :authenticate_devise_api_token!

  def index
    @users = User.where(active: true).all
    render json: @users, status: :ok
  end

  def show
    @user = current_devise_api_user
    render json:  {
      id: @user.id,
      username: @user.username,
      is_admin: @user.is_admin
    }, status: :ok
  end
end
