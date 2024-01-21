class CreateSubscriptionPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :subscription_plans do |t|
      t.string :name
      t.string :description
      t.integer :activation_months
      t.decimal :price

      t.timestamps
    end
  end
end
