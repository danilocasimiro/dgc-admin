# frozen_string_literal: true

class CompaniesController < AddressableController
  include UserContext

  def index
    @models = model_class.with_user_id(current_user.id)

    render json: @models
  end

  def model
    @model = Company.with_user_id(current_user.id).find(params[:id])
  end

  def model_params
    params.require(:company).permit(:name).merge(tenant_id: current_user.id)
  end

  def addressable_params
    params
      .permit(:street, :number, :neighborhood, :city, :state)
      .merge({ addressable_id: params[:company_id], addressable_type: 'Company' })
  end
end
