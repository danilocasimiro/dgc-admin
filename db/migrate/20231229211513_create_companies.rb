class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.references :user, foreign_key: true
      t.string :email_address

      t.timestamps
    end
  end
end
