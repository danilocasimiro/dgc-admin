class CompanyEmailTemplate < ApplicationRecord
  belongs_to :company, inverse_of: :company_email_templates
  belongs_to :email_template, inverse_of: :company_email_templates

  validates_presence_of :subject, :body

  validate :unique_email_template_company_combination

  private

  def unique_email_template_company_combination
    if self.where(email_template_id:, company_id:).exists?
      errors.add(:base, "Este template de email já está associado a esta empresa")
    end
  end
end
