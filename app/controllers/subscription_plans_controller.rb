# frozen_string_literal: true

class SubscriptionPlansController < BaseController
  include UserContext

  def index
    @models = model_class.all

    render json: @models.as_json(include: include_associations)
  end
end
