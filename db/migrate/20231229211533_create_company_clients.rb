class CreateCompanyClients < ActiveRecord::Migration[7.1]
  def change
    create_table :company_clients do |t|
      t.references :client, foreign_key: true
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
