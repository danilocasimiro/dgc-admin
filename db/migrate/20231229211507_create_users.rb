class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.references :profile, polymorphic: true, index: true, null: true
      t.bigint :friendly_id
      t.string :email_address
      t.string :password_digest


      t.timestamps
    end

    add_index :users, :friendly_id, unique: true
  end
end
