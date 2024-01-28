# frozen_string_literal: true

class SystemConfigurationsController < BaseController
  before_action :set_resource, only: %i[update show]

  private

  def permitted_params
    params.require(:system_configuration).permit(%i[maintenance_mode grace_period_days])
  end
end
