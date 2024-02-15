# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :subscription_plan, inverse_of: :subscriptions
  belongs_to :tenant, inverse_of: :subscriptions

  scope :with_tenant_id, ->(tenant_id) { where(tenant_id:) }

  enum status: %i[active inactive suspended pending]

  before_save :add_start_at, :add_end_at

  validates :status, inclusion: { in: Subscription.statuses.keys }

  validates_presence_of :status, :start_at
  validates_timeliness :start_at, :end_at, type: :date, format: "%Y-%m-%d"

  private

  def add_start_at
    self.start_at = Date.today
  end

  def add_end_at
    self.end_at = Date.today.advance(months: fetch_activation_months)
  end

  def fetch_activation_months
    SubscriptionPlan.select(:activation_months).find(subscription_plan_id).activation_months
  end

  class << self
    def relation_map
      %i[subscription_plan tenant]
    end
  end
end
