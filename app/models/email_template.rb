class EmailTemplate < ApplicationRecord
  has_many :company_email_templates, inverse_of: :email_template

  validates_presence_of :action, :subject, :body
end
