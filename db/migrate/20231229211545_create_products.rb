class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.references :product_type, foreign_key: true
      t.string :name
      t.decimal :price

      t.timestamps
    end
  end
end
