class Api::V1::CoursesController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :set_course, only: %i[show update destroy]

  def index
    courses = Course.order(created_at: :desc)
    
    if params[:active_only].present?
      courses = courses.active
    end

    render json: courses.as_json(only: %i[id name active created_at]), status: :ok
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
end
