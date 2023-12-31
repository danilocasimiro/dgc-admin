# frozen_string_literal: true

module UserContext
  extend ActiveSupport::Concern

  included do
    before_action :user_authenticate?
  end
end
