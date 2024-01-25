# frozen_string_literal: true

class TenantsController < BaseController
  include UserContext

  after_action :create_user, only: :create
  after_action :update_user, only: :update
  before_action :set_resource, only: %i[show update destroy]
  before_action :user_authenticate?, except: %i[create]

  def index
    @models =
      current_user.admin? ? model_class.all : model_class.with_user_id(current_user.id)

    render json: @models.as_json(include: include_associations)
  end

  private

  def user_params
    params.permit(%i[email_address password])
  end

  def permitted_params
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
