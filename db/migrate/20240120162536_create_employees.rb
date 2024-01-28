class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.references :tenant, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
