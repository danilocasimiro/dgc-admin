class CompanyEmailTemplate < ApplicationRecord
  belongs_to :company, inverse_of: :company_email_templates
  belongs_to :email_template, inverse_of: :company_email_templates

  validates_presence_of :subject, :body

  validate :unique_email_template_company_combination, on: :create

  scope :with_company_id, ->(company_id) { where(company_id:) }

  private

  def unique_email_template_company_combination
    if CompanyEmailTemplate.where(email_template_id:, company_id:).exists?
      errors.add(:base, "Este template de email já está associado a esta empresa")
    end
  end
end
