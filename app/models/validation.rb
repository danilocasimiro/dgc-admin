class Validation < ApplicationRecord
  belongs_to :user, inverse_of: :validations

  enum status: %i[pending canceled used]
  enum validation_type: %i[registration password_recovery]

  validates :status, inclusion: { in: Validation.statuses.keys }
  validates :validation_type, inclusion: { in: Validation.validation_types.keys }, presence: true
end
