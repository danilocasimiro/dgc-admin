# frozen_string_literal: true

class SubscriptionPlan < ApplicationRecord
  has_many :subscriptions, inverse_of: :subscription_plan

  class << self
    def relation_map
      %i[subscriptions]
    end
  end
end
