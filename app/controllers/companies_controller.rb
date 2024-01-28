# frozen_string_literal: true

class CompaniesController < BaseController
  include UserContext

  before_action :set_resource, only: %i[show destroy update]

  def index
    @models = model_class.with_user_id(current_user.id)

    render json: @models.as_json(include: include_associations)
  end

  def create
    @model = model_class.create!(permitted_params)
    store_address

    render json: @model
  end

  def update
    @model.update!(permitted_params)
    update_address

    render json: @model
  end

  private

  def set_resource
    @model = model_class.with_user_id(current_user.id).find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name).merge(tenant_id: current_user.profile_id)
  end
end
