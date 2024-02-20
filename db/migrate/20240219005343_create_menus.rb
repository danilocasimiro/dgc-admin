class CreateMenus < ActiveRecord::Migration[7.1]
  def change
    create_table :menus do |t|
      t.integer :parent_id
      t.string :label
      t.string :link
      t.string :icon
      t.integer :company, default: 0, null: false
      t.string :users_allowed

      t.timestamps
    end
  end
end
