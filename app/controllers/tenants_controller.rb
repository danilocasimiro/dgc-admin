# frozen_string_literal: true

class TenantsController < BaseController
  include UserContext

  before_action :set_resource, only: %i[show update destroy]
  before_action :user_authenticate?, :allow_access?, except: %i[create]

  def index
    @models = model_class.accessible_by_user(current_user)

    render json: paginate(@models)
  rescue ForbiddenError
    raise ForbiddenError
  end

  def create
    tenant_data = permitted_params.slice(*model_class.column_names.map(&:to_sym))
    tenant_data[:affiliate_id] = current_user.profile_id if current_user.type == Affiliate

    @model = model_class.create!(tenant_data)
    create_user
    send_email
    render json: @model
  end

  def update
    return raise ForbiddenError unless user_has_permission?

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
    return unless @model.persisted?

    origin = request.headers['Origin'] || request.headers['Referer']

    UserRegistrationMailer.send_email(@model.user, origin).deliver_now
  end
end
