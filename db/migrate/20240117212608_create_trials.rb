class CreateTrials < ActiveRecord::Migration[7.1]
  def change
    create_table :trials do |t|
      t.references :tenant, foreign_key: true
      t.date :start_at
      t.date :end_at

      t.timestamps
    end
  end
end
