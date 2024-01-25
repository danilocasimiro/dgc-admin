# frozen_string_literal: true

class ProductTypesController < BaseController
  include CompanyContext

  before_action :set_resource, only: %i[show update destroy]

  def index
    @models = model_class.with_company_id(current_company_id)

    render json: @models.as_json(include: include_associations)
  end

  private

  def set_resource
    @model = model_class.with_company_id(current_company_id).find(params[:id])
  end

  def permitted_params
    params.require(:product_type).permit(:name).merge(company_id: current_company_id)
  end
end
