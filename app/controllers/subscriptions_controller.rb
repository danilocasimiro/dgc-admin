# frozen_string_literal: true

class SubscriptionsController < BaseController
  include UserContext

  before_action :set_resource, only: %i[show update destroy]

  def index
    @models =
      current_user.admin? ? model_class.all : filter_by_tenant

    render json: paginate(@models)
  end

  def create
    raise ForbiddenError unless current_user.tenant?

    @model = model_class.create!(permitted_params)

    render json: @model
  end

  private

  def permitted_params
    params.require(:subscription)
          .permit(:status, :subscription_plan_id)
          .merge({ tenant_id: current_user.profile.id })
  end

  def filter_by_tenant
    raise ForbiddenError unless current_user.tenant?

    model_class.with_tenant_id(current_user.profile_id)
  end

  def set_resource
    raise ForbiddenError unless current_user.tenant?

    @model = model_class.with_tenant_id(current_user.profile_id).where(tenant_id: current_user.profile.id)
  end
end
