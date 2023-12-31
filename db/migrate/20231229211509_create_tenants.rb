class CreateTenants < ActiveRecord::Migration[7.1]
  def change
    create_table :tenants do |t|
      t.references :user, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
