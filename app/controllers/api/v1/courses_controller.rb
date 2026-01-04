class Api::V1::CoursesController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_course, only: %i[show update destroy]

  def index
    render_courses_response
  end

  def show
    render json: @course.as_json(only: %i[id name active created_at]), status: :ok
  end

  def create
    @course = Course.new(course_params)

    if @course.save
      render json: @course.as_json(only: %i[id name active created_at]), status: :created
    else
      render json: @course.errors, status: :unprocessable_entity
    end
  end

  def update
    if @course.update(course_params)
      render json: @course.as_json(only: %i[id name active created_at]), status: :ok
    else
      render json: @course.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @course.procedures.exists?
      render json: { error: 'Course has associated procedures and cannot be deleted.' }, status: :conflict
    elsif @course.destroy
      render json: { message: 'Course successfully deleted.' }, status: :ok
    else
      render json: @course.errors, status: :unprocessable_entity
    end
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:name, :active)
  end

  def render_courses_response
    courses = filtered_courses

    if params[:full] == 'true'
      render json: courses.as_json(only: %i[id name active created_at]), status: :ok
    else
      render json: {
        courses: courses.as_json(only: %i[id name active created_at]),
        pagination: {
          total_pages: courses.total_pages,
          current_page: courses.current_page,
          next_page: courses.next_page,
          prev_page: courses.prev_page,
          total_count: courses.total_count
        }
      }, status: :ok
    end
  end

  def filtered_courses
    courses = Course.order(created_at: :desc)

    courses = courses.active if ActiveModel::Type::Boolean.new.cast(params[:active_only])

    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      courses = courses.where('LOWER(name) LIKE ?', search_term)
    end

    start_date_param = params[:start_date] || params[:startDate]
    end_date_param = params[:end_date] || params[:endDate]

    if start_date_param.present?
      start_date = start_date_param.to_date.beginning_of_day
      courses = courses.where('created_at >= ?', start_date)
    end

    if end_date_param.present?
      end_date = end_date_param.to_date.end_of_day
      courses = courses.where('created_at <= ?', end_date)
    end

    return courses if params[:full] == 'true'

    courses.page(params[:page]).per(15)
  end
end
