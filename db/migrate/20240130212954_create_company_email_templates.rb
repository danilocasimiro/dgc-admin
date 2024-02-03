class CreateCompanyEmailTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :company_email_templates do |t|
      t.references :email_template, foreign_key: true
      t.references :company, foreign_key: true
      t.string :subject
      t.text :body

      t.timestamps
    end
  end
end
