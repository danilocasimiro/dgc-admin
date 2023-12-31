# frozen_string_literal: true

class ProductsController < BaseController
  def model_params
    params.require(:product).permit(:name, :product_type_id, :price)
  end
end
