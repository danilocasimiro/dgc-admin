class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.references :tenant, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
