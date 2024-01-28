class CreateCompanyEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :company_employees do |t|
      t.references :company, foreign_key: true
      t.references :employee, foreign_key: true

      t.timestamps
    end
  end
end
