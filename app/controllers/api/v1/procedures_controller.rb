class Api::V1::ProceduresController < ApplicationController
  before_action :authenticate_devise_api_token!

  def index
    render_procedures_response
  end

  private

  def render_procedures_response
    render json: {
      procedures: all_procedures,
      stats: calculate_statistics
    }, status: :ok
  end

  def calculate_statistics
    {
      procedures_quantity: Procedure.count,
      procedures_added_last_month: Procedure.where('created_at >= ?', 1.month.ago).count,
      procedures_added_last_7_days: Procedure.where('created_at >= ?', 7.days.ago).count
    }
  end

  def all_procedures
    Procedure.order(created_at: :asc).all
  end
end
