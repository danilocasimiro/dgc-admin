# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true, dependent: :destroy

  validates_presence_of :street, :number, :neighborhood, :city, :state, :zip_code
  validates_format_of :zip_code, with: /\A\d{5}-\d{3}\z/,
    message: "formato de CEP inválido. Use o formato: XXXXX-XXX"

end
