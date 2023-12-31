# frozen_string_literal: true

class ProductTypesController < BaseController
  include CompanyContext

  def index
    @models = model_class.with_company_id(current_company_id)

    render json: @models
  end

  def model
    @model = model_class.with_company_id(current_company_id).find(params[:id])
  end

  def model_params
    params.require(:product_type).permit(:name).merge(company_id: current_company_id)
  end
end
