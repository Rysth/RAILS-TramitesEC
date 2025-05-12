class Api::V1::AgenciesController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_agency, only: %i[show update destroy]

  def index
    render_agencies_response
  end

  def show
    render json: @agency
  end

  def create
    @agency = Agency.new(agency_params)

    if @agency.save
      render json: @agency, status: :created
    else
      render json: @agency.errors, status: :unprocessable_entity
    end
  end

  def update
    if @agency.update(agency_params)
      render json: @agency, status: :ok
    else
      render json: @agency.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @agency.destroy
      render json: { message: 'Agency successfully deleted.' }, status: :ok
    else
      render json: @agency.errors, status: :unprocessable_entity
    end
  end

  private

  def render_agencies_response
    agencies = all_agencies

    if params[:full] == 'true'
      render json: {
        agencies:
      }, status: :ok
    else
      render json: {
        agencies:,
        pagination: {
          total_pages: agencies.total_pages,
          current_page: agencies.current_page,
          next_page: agencies.next_page,
          prev_page: agencies.prev_page,
          total_count: agencies.total_count
        }
      }, status: :ok
    end
  end

  def all_agencies
    agencies = Agency.order(created_at: :desc)

    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      agencies = agencies.where('LOWER(name) LIKE :search OR LOWER(code) LIKE :search', search: search_term)
    end

    if params[:startDate].present? && params[:endDate].present?
      start_date = (params[:startDate].to_date + 1.day).beginning_of_day
      end_date = (params[:endDate].to_date + 1.day).end_of_day
      agencies = agencies.where(created_at: start_date..end_date)
    elsif params[:startDate].present?
      agencies = agencies.where('created_at >= ?', params[:startDate])
    elsif params[:endDate].present?
      agencies = agencies.where('created_at <= ?', params[:endDate])
    end

    if params[:full] == 'true'
      agencies
    else
      agencies.page(params[:page]).per(15)
    end
  end

  def set_agency
    @agency = Agency.find(params[:id])
  end

  def agency_params
    params.require(:agency).permit(:name, :active, :has_licenses)
  end
end
