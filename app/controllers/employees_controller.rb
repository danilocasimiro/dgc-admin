# frozen_string_literal: true

class EmployeesController < BaseController
  include UserContext

  before_action :set_resource, only: %i[show update destroy]

  def index
    @models = model_class.all

    render json: @models.as_json(include: include_associations)
  end

  def create
    @model = model_class.create!(permitted_params)
    create_user

    render json: @model
  end

  def update
    @model.update!(permitted_params)
    update_user

    render json: @model
  end

  private

  def permitted_params
    params.require(:employee)
          .permit(:name)
          .merge(employable_data)
  end

  def user_params
    params.permit(:email_address, :password)
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
