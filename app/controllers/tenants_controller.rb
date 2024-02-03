# frozen_string_literal: true

class TenantsController < BaseController
  include UserContext

  before_action :set_resource, only: %i[show update destroy]
  before_action :user_authenticate?, :allow_access?, except: %i[create]

  def index
    @models =
      current_user.admin? ? model_class.all : model_class.with_user_id(current_user.id)

    render json: @models.as_json(include: include_associations)
  end

  def create
    @model = model_class.create!(permitted_params)
    create_user
    send_email
    render json: @model
  end

  def update
    @model.update!(permitted_params)
    update_user

    render json: @model
  end

  private

  def user_params
    params.require(:user).permit(%i[email_address password])
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

  def send_email
    if @model.persisted?
      origin = request.headers['Origin'] || request.headers['Referer']

      UserRegistrationMailer.send_email(@model.user, origin).deliver_now
    end
  end
end
