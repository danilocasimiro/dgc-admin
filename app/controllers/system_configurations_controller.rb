# frozen_string_literal: true

class SystemConfigurationsController < BaseController
  before_action :set_resource, only: %i[update show]

  def maintenance_mode
    render json: SystemConfiguration.first.maintenance_mode
  end

  private

  def permitted_params
    params.require(:system_configuration).permit(%i[maintenance_mode grace_period_days])
  end

  def set_resource
    raise ForbiddenError unless current_user.admin?

    @model = model_class.find(params[:id])
  end
end
