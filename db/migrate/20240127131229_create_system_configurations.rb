class CreateSystemConfigurations < ActiveRecord::Migration[7.1]
  def change
    create_table :system_configurations do |t|
      t.boolean :maintenance_mode, default: false
      t.integer :grace_period_days, default: 0

      t.timestamps
    end
  end
end
