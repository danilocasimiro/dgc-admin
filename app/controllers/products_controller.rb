# frozen_string_literal: true

class ProductsController < BaseController
  include CompanyContext

  before_action :set_resource, only: %i[show update destroy]

  def index
    @models = model_class.with_company_id(current_company_id)

    render json: @models.as_json(include: include_associations)
  end

  def show
    render json: @model.as_json(include: include_associations)
  end

  def create
    @model = model_class.new(product_params)
    if @model.save
      render json: @model
    else
      render json: { errors: }, status: :bad_request
    end
  end

  def update
    @model.update(product_params)

    render json: @model
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

  def set_resource
    @model = model_class.with_company_id(current_company_id).find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :product_type_id, :price)
  end
end
