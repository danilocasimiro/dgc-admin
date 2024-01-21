# frozen_string_literal: true

class EmployeesController < BaseController
  before_action :set_resource, only: %i[show update destroy]

  def index
    @models = model_class.all

    render json: @models.as_json(include: include_associations)
  end

  def show
    render json: @model.as_json(include: include_associations)
  end

  def update
    if @model.update(employee_params.merge(employable_data))
      render json: @model
    else
      render json: { errors: }, status: :bad_request
    end
  end

  def create
    @model = model_class.new(employee_params.merge(employable_data))

    if @model.save
      render json: @model
    else
      render json: { errors: }, status: :bad_request
    end
  end

  def destroy
    @model.destroy

    if @model.errors.present?
      render json: { errors: }, status: :bad_request
    else
      head :ok
    end
  end

  private

  def set_resource
    @model = model_class.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:name)
  end

  def employable_data
    employable_id = params.dig(:employee, :employable_id)

    if employable_id.present?
      { employable_id:, employable_type: 'Company' }
    else
      { employable_id: current_user.profile.id, employable_type: 'Tenant' }
    end
  end
end
