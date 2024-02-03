# frozen_string_literal: true

class UsersController < BaseController
  include UserContext

  before_action :set_resource, only: %i[show update]

  before_action :user_authenticate?, :allow_access?, except: %i[activate]

  def show
    if @model.admin?
      render json: { user: @model.as_json }
    else
      render json: @model.profile.as_json(include: :user)
    end
  end

  def update
    @model.update!(permitted_params.reject { |_, value| value.blank? })
    @model.profile.update!(profile_params) if @model.profile && profile_params

    render json: @model
  end

  def activate
    validator = Validation.find_by!(
      user_id: activate_params[:user_id],
      token: activate_params[:token],
      validation_type: activate_params[:validation_type],
      status: 0
    )

    validator.update!(status: 2)
    validator.user.update!(status: 0)
  end

  private

  def permitted_params
    params.require(:user).permit(:email_address, :password)
  end

  def activate_params
    params.permit(:token, :user_id, :validation_type)
  end

  def profile_params
    params.permit(:name)
  end
end
