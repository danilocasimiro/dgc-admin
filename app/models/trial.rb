# frozen_string_literal: true

class Trial < ApplicationRecord
  belongs_to :tenant, inverse_of: :trial

  validates_presence_of :start_at, :end_at
  validates_comparison_of :end_at, greater_than: :start_at
end
