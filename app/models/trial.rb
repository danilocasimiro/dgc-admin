# frozen_string_literal: true

class Trial < ApplicationRecord
  belongs_to :tenant, inverse_of: :trial

  validates_presence_of :start_at, :end_at
  validates_timeliness :start_at, :end_at, type: :date, format: "%Y-%m-%d"
end
