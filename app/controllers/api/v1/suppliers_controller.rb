# app/controllers/api/v1/suppliers_controller.rb
class Api::V1::SuppliersController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_supplier, only: %i[show update destroy]

  def index
    render_suppliers_response
  end

  def show
    render json: @supplier, status: :ok
  end

  def create
    @supplier = Supplier.new(supplier_params)
    @supplier.user_id = current_devise_api_user.id

    if @supplier.save
      render json: @supplier, status: :created
    else
      render json: @supplier.errors, status: :unprocessable_entity
    end
  end

  def update
    if @supplier.update(supplier_params)
      render json: @supplier, status: :ok
    else
      render json: @supplier.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @supplier.destroy
      render json: { message: 'Supplier successfully deleted.' }, status: :ok
    else
      render json: @supplier.errors, status: :unprocessable_entity
    end
  end

  def search_suppliers
    query = "%#{params[:query].downcase}%"
    suppliers = if query.blank?
                  Supplier.order(created_at: :desc).page(1)
                else
                  Supplier.where('LOWER(identification) LIKE :query OR LOWER(name) LIKE :query', query: "%#{query}%").order(created_at: :desc).page(1)
                end
    render json: suppliers.as_json(only: %i[id identification name])
  end

  def generate_excel
    # Query suppliers within the specified date range
    suppliers = Supplier.includes(:user).all

    # Generate Excel file using axlsx_rails gem
    package = Axlsx::Package.new
    workbook = package.workbook
    workbook.add_worksheet(name: 'Proveedores') do |sheet|
      # Add headers
      header_rows = ['ID', 'Usuario', 'Identificación', 'Nombre Completo', 'Teléfono', 'Fecha de Creación']
      sheet.add_row header_rows

      # Add data for each supplier
      suppliers.each do |supplier|
        body_rows = [
          supplier.id,
          supplier.user.username,
          supplier.identification,
          supplier.name,
          supplier.phone,
          supplier.created_at
        ]
        sheet.add_row body_rows
      end
    end

    # Set the content type for the response and send the file
    send_data package.to_stream.read, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', filename: 'proveedores.xlsx'
  end

  private

  def render_suppliers_response
    suppliers = all_suppliers
    render json: {
      suppliers: suppliers.as_json(
        only: %i[id identification name phone email active],
        include: {
          user: {
            only: %i[id username]
          }
        }
      ),
      pagination: {
        total_pages: suppliers.total_pages,
        current_page: suppliers.current_page,
        next_page: suppliers.next_page,
        prev_page: suppliers.prev_page,
        total_count: suppliers.total_count
      }
    }, status: :ok
  end

  def all_suppliers
    suppliers = Supplier.includes(:user).order(created_at: :desc)

    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      suppliers = suppliers.where('LOWER(identification) LIKE :search OR LOWER(name) LIKE :search', search: search_term)
    end

    suppliers = suppliers.where(user_id: params[:userId]) if params[:userId].present?

    if params[:startDate].present? && params[:endDate].present?
      start_date = (params[:startDate].to_date + 1.day).beginning_of_day
      end_date = (params[:endDate].to_date + 1.day).end_of_day
      suppliers = suppliers.where(created_at: start_date..end_date)
    elsif params[:startDate].present?
      suppliers = suppliers.where('created_at >= ?', params[:startDate])
    elsif params[:endDate].present?
      suppliers = suppliers.where('created_at <= ?', params[:endDate])
    end

    suppliers.page(params[:page]).per(15)
  end

  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(:identification, :name, :phone, :email)
  end
end
