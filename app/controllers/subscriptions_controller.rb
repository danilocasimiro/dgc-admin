# frozen_string_literal: true

class SubscriptionsController < BaseController
  include UserContext

  def index
    @models =
      current_user.admin? ? model_class.all : model_class.with_tenant_id(current_user.tenant_id)

    render json: @models.as_json(include: include_associations)
  end
end
