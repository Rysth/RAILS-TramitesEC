class Api::V1::ProfileController < ApplicationController
  before_action :authenticate_devise_api_token!

  def index
    @user_processors = current_devise_api_user.processors
    quantity_and_months = calculate_quantity_and_months(@user_processors)

    render json: quantity_and_months, status: :ok
  end

  private

  def calculate_quantity_and_months(processors)
    quantity_and_months = []

    (0..5).reverse_each do |i|
      month_start = i.months.ago.beginning_of_month
      month_end = i.months.ago.end_of_month

      processors_data = processors.where(created_at: month_start..month_end)
      quantity_and_months << {
        Meses: month_start.strftime('%B %Y'),
        Trámitadores: processors_data.count,
        Clientes: calculate_customers_count(processors_data)
      }
    end

    quantity_and_months
  end

  def calculate_customers_count(processors_data)
    processors_data.includes(:customers).sum { |processor| processor.customers.count }
  end

end