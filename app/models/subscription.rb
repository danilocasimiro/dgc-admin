# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :subscription_plan, inverse_of: :subscriptions
  belongs_to :tenant, inverse_of: :subscriptions

  scope :with_tenant_id, ->(tenant_id) { where(tenant_id:) }

  enum status: %i[active inactive suspended]

  validates :status, inclusion: { in: Subscription.statuses.keys }

  class << self
    def relation_map
      %i[subscription_plan tenant]
    end
  end
end
