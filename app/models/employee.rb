# frozen_string_literal: true

class Employee < ApplicationRecord
  belongs_to :employable, polymorphic: true, dependent: :destroy

  has_one :user, as: :profile, inverse_of: :profile, dependent: :destroy

  class << self
    def relation_map
      %i[employable]
    end
  end
end
