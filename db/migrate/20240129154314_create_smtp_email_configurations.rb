class CreateSmtpEmailConfigurations < ActiveRecord::Migration[7.1]
  def change
    create_table :smtp_email_configurations do |t|
      t.boolean :active, default: false
      t.string :address
      t.string :name
      t.string :user_name
      t.string :password
      t.string :port
      t.string :domain
      t.string :authentication

      t.timestamps
    end
  end
end
