class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :tenant, foreign_key: true
      t.references :subscription_plan, foreign_key: true
      t.string :status
      t.date :start_at
      t.date :end_at

      t.timestamps
    end
  end
end
