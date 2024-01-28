# frozen_string_literal: true

module UserContext
  extend ActiveSupport::Concern

  included do
    before_action :user_authenticate?
    before_action :allow_access?
  end

  private

  def allow_access?
    return unless current_user.profile

    return if current_user.profile.allow_access?

    render json: { error: 'Sua assinatura está expirada. Por favor, realize uma nova assinatura.' },
           status: :unauthorized
  end
end
