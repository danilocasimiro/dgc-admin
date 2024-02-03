class CreateValidations < ActiveRecord::Migration[7.1]
  def change
    create_table :validations do |t|
      t.references :user, foreign_key: true
      t.integer :validation_type
      t.string :token
      t.integer :status

      t.timestamps
    end
  end
end
