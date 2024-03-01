# frozen_string_literal: true

class ProductsController < BaseController
  include CompanyContext

  before_action :user_has_permission?
  before_action :set_resource, only: %i[show update destroy]

  def index
    @models = model_class.with_company_id(current_company_id)

    render json: paginate(@models)
  end

  private

  def user_has_permission?
    raise ForbiddenError unless current_user.tenant? || current_user.employee?
  end

  def set_resource
    @model = model_class.with_company_id(current_company_id).find(params[:id])
  end

  def permitted_params
    params.require(:product).permit(:name, :product_type_id, :price)
  end
end
