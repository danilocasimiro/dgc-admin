class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.references :employable, polymorphic: true, index: true
      t.string :name

      t.timestamps
    end
  end
end
