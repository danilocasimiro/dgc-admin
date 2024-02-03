class CreateEmailTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :email_templates do |t|
      t.string :action
      t.string :subject
      t.text :body
      t.string :allow_variables

      t.timestamps
    end
  end
end
