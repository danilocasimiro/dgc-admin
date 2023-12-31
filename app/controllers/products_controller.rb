# frozen_string_literal: true

class ProductsController < BaseController
  include CompanyContext

  def index
    @models = model_class.with_company_id(current_company_id)

    render json: @models
  end

  def model
    @model = model_class.with_company_id(current_company_id).find(params[:id])
  end

  def model_params
    params.require(:product).permit(:name, :product_type_id, :price)
  end
end
