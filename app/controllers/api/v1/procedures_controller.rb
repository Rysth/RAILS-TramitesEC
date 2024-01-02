class Api::V1::ProceduresController < ApplicationController
  before_action :authenticate_devise_api_token!

  def index
    render_procedures_response
  end

  private

  def render_procedures_response
    # Retrieve all the information related
    procedures_data = all_procedures.as_json(
      include: {
        customer: {
          only: %i[id cedula nombres apellidos]
        },
        user: {
          only: %i[id username]
        },
        processor: {
          only: %i[id nombres apellidos]
        },
        license: {
          only: %i[id nombre]
        },
        status: {
          only: %i[id nombre]
        }
      }
    )

    render json: {
      procedures: procedures_data,
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
    Procedure.includes(:customer, :processor, :user, :license, :status).order(created_at: :asc).all
  end
end
