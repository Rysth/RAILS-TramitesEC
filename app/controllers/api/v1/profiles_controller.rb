class Api::V1::ProfilesController < ApplicationController
  before_action :authenticate_devise_api_token!

  def show
    @user_profile = current_devise_api_user
    quantity_and_months = calculate_quantity_and_months

    render json: quantity_and_months, status: :ok
  end

  private

  def calculate_quantity_and_months
    quantity_and_months = []

    (0..5).reverse_each do |i|
      month_start = i.months.ago.beginning_of_month
      month_end = i.months.ago.end_of_month

      processors_data = @user_profile.processors.includes(:customers).where(created_at: month_start..month_end)
      procedures_data = @user_profile.procedures.where(created_at: month_start..month_end)
      customers_data = @user_profile.customers.where(created_at: month_start..month_end)

      quantity_and_months << {
        Meses: month_start.strftime('%B %Y'),
        Tramitadores: processors_data.count,
        Clientes: customers_data.count,
        Tramites: procedures_data.count
      }
    end

    quantity_and_months
  end
end
