# frozen_string_literal: true

class Trial < ApplicationRecord
  belongs_to :tenant, inverse_of: :trial
end
