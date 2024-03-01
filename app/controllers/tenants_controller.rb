# frozen_string_literal: true

class TenantsController < BaseController
  include UserContext

  before_action :allow_access?, except: %i[create]
  before_action :set_resource, only: %i[show update destroy]

  def index
    @models = model_class.accessible_by_user(current_user)

    render json: paginate(@models)
  end

  def create
    raise ForbiddenError unless current_user.admin? || current_user.affiliate?

    tenant_data = permitted_params.slice(*model_class.column_names.map(&:to_sym))
    tenant_data[:affiliate_id] = current_user.profile_id if current_user.affiliate?

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

  def send_email
    return unless @model.persisted?

    origin = request.headers['Origin'] || request.headers['Referer']

    UserRegistrationMailer.send_email(@model.user, origin).deliver_now
  end
end
