# frozen_string_literal: true

class SubscriptionsController < BaseController
  include UserContext

  def index
    @models =
      current_user.admin? ? model_class.all : filter_by_tenant

    render json: @models.as_json(include: include_associations)
  end

  private

  def permitted_params
    params.require(:subscription)
          .permit(:status, :subscription_plan_id)
          .merge({ tenant_id: current_user.profile.id })
  end

  def filter_by_tenant
    return [] unless current_user.profile.is_a?(Tenant)

    model_class.with_tenant_id(current_user.profile_id)
  end
end
