# frozen_string_literal: true

class SubscriptionPlan < ApplicationRecord
  has_many :subscriptions, inverse_of: :subscription_plan

  validates_presence_of :name, :activation_months, :price
  validates_uniqueness_of :name
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :activation_months, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  class << self
    def relation_map
      %i[subscriptions]
    end
  end
end
