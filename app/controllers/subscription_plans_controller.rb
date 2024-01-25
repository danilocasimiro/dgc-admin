# frozen_string_literal: true

class SubscriptionPlansController < BaseController
  include UserContext

  before_action :set_resource, only: %i[show update destroy]

  def index
    @models = model_class.all

    render json: @models.as_json(include: include_associations)
  end

  def show
    render json: @model.as_json(include: include_associations)
  end

  def update
    if @model.update(subscription_plan_params)
      render json: @model
    else
      render json: { errors: }, status: :bad_request
    end
  end

  def create
    @model = model_class.new(subscription_plan_params)

    if @model.save
      render json: @model
    else
      render json: { errors: }, status: :bad_request
    end
  end

  def destroy
    @model.destroy

    if @model.errors.present?
      render json: { errors: }, status: :bad_request
    else
      head :ok
    end
  end

  private

  def subscription_plan_params
    params.require(:subscription_plan).permit(:name, :description, :activation_months, :price)
  end

  def set_resource
    @model = model_class.find(params[:id])
  end
end
