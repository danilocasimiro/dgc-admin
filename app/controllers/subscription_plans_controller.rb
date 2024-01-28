# frozen_string_literal: true

class SubscriptionPlansController < BaseController
  include UserContext

  before_action :set_resource, only: %i[show update destroy]

  def index
    @models = model_class.all

    render json: @models.as_json(include: include_associations)
  end

  private

  def permitted_params
    params.require(:subscription_plan).permit(:name, :description, :activation_months, :price)
  end
end
