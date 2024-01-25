# frozen_string_literal: true

class CompaniesController < BaseController
  include UserContext

  after_action :store_address, only: :create
  after_action :update_address, only: :update

  before_action :set_resource, only: %i[show destroy update]

  def index
    @models = model_class.with_user_id(current_user.id)

    render json: @models.as_json(include: include_associations)
  end

  private

  def set_resource
    @model = Company.with_user_id(current_user.id).find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name).merge(tenant_id: current_user.profile_id)
  end
end
