# frozen_string_literal: true

class ProductTypesController < BaseController
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
    @model = model_class.create!(product_type_params)
    if @model.save
      render json: @model
    else
      render json: errors
    end
  end

  def update
    @model.update(product_type_params)

    render json: @model
  end

  def destroy
    @model.destroy

    if @model.errors.present?
      render json: errors
    else
      head :ok
    end
  end

  private

  def set_resource
    @model = model_class.with_company_id(current_company_id).find(params[:id])
  end

  def product_type_params
    params.require(:product_type).permit(:name).merge(company_id: current_company_id)
  end
end
