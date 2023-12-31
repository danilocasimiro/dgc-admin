# frozen_string_literal: true

class ProductTypesController < BaseController
  def model_params
    params.require(:product_type).permit(:name, :company_id)
  end
end
