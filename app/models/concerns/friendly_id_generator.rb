# frozen_string_literal: true

module FriendlyIdGenerator
  extend ActiveSupport::Concern

  def generate_friendly_id(company_id = nil)
    query = self.class
    query = query.with_company_id(company_id) if company_id.present?
    last_id = query.maximum(:friendly_id) || 0
    self.friendly_id ||= last_id + 1
  end
end
