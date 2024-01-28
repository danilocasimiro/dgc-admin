# frozen_string_literal: true

class UsersController < BaseController
  include UserContext

  before_action :set_resource, only: %i[show update]

  def show
    if @model.admin?
      render json: { user: @model.as_json }
    else
      render json: @model.profile.as_json(include: :user)
    end
  end

  def update
    @model.update!(permitted_params)
    @model.profile.update!(profile_params) if @model.profile && profile_params

    render json: @model
  end

  private

  def permitted_params
    params.require(:user).permit(:email_address, :password)
  end

  def profile_params
    params.permit(:name)
  end
end
