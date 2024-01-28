# frozen_string_literal: true

class CompaniesController < BaseController
  include UserContext

  before_action :set_resource, only: %i[show destroy update]

  def index
    @models = current_user.profile.companies

    render json: @models.as_json(include: include_associations)
  end

  def create
    @model = model_class.create!(permitted_params.merge(tenant_id: current_user.profile_id))
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
    @model = current_user.profile.companies.find(params[:id])
  end

  def permitted_params
    params.require(:company).permit(:name)
  end
end
