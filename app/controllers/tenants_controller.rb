# frozen_string_literal: true

class TenantsController < AddressableController
  include UserContext

  def index
    @models = Tenant.with_user_id(current_user.id)

    render json: @models
  end

  def create
    super
    Tenant.create!(tenant_params.merge(user_id: @model.id))
  end

  def model_params
    params.permit(:email_address, :password)
  end

  def tenant_params
    params.require(:tenant).permit(:name)
  end

  def model_class
    User
  end

  def model
    @model = Tenant.with_user_id(current_user.id).find(params[:id])
  end

  def addressable_params
    params
      .permit(:street, :number, :neighborhood, :city, :state)
      .merge({ addressable_id: params[:tenant_id], addressable_type: 'User' })
  end
end
