# frozen_string_literal: true

class TenantsController < BaseController
  include UserContext

  before_action :set_resource, only: %i[show update destroy]
  before_action :user_authenticate?, except: %i[create]

  def index
    @models =
      current_user.admin? ? model_class.all : model_class.with_user_id(current_user.id)

    render json: @models.as_json(include: include_associations)
  end

  def show
    render json: @model.as_json(include: include_associations)
  end

  def create
    @model = model_class.create!(tenant_params)
    @user = User.create!(user_params.merge({ profile_type: @model.class, profile_id: @model.id }))

    if @model.save
      render json: @model
    else
      render json: { errors: }, status: :bad_request
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
      render json: { errors: }, status: :bad_request
    else
      head :ok
    end
  end

  private

  def user_params
    params.permit(%i[email_address password])
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
