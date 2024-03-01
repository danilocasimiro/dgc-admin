class Affiliate < ApplicationRecord
  has_many :tenants, inverse_of: :affiliate

  has_one :user, as: :profile, inverse_of: :profile, dependent: :destroy

  validates_presence_of :name

  class << self
    def relation_map
      %i[user]
    end
  end
end
