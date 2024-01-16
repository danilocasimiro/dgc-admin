# frozen_string_literal: true

class TenantsController < BaseController
  include UserContext

  before_action :set_resource, only: %i[show update destroy]

  def index
    @models =
      current_user.admin? ? model_class.all : model_class.with_user_id(current_user.id)

    render json: @models.as_json(include: include_associations)
  end

  def show
    render json: @model.as_json(include: include_associations)
  end

  def create
    @user = User.create!(user_params)
    @model = @user.build_tenant(tenant_params)
    @model.friendly_id = @model.generate_friendly_id

    if @model.save
      render json: @model
    else
      render json: errors
    end
  end

  def update
    @model.update(tenant_params)
    @model.user.update(user_params) if user_params

    render json: @model.as_json(include: %i[user])
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

  def user_params
    params.require(:user).permit(%i[email_address password])
  end

  def tenant_params
    params.require(:tenant).permit(:name)
  end

  def set_resource
    @model =
      if current_user.admin?
        model_class.find(params[:id])
      else
        model_class.with_user_id(current_user.id).find(params[:id])
      end
  end
end
