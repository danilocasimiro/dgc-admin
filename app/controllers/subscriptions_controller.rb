# frozen_string_literal: true

class SubscriptionsController < BaseController
  include UserContext

  def index
    @models =
      current_user.admin? ? model_class.all : filter_by_tenant

    render json: @models.as_json(include: include_associations)
  end

  def create
    @model = model_class.new(subscription_params)
    @model.tenant_id = current_user.tenant.id
    if @model.save
      render json: @model
    else
      render json: { errors: }, status: :bad_request
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(:status, :subscription_plan_id)
  end

  def filter_by_tenant
    return [] unless current_user.profile.is_a?(Tenant)

    model_class.with_tenant_id(current_user.profile_id)
  end
end
