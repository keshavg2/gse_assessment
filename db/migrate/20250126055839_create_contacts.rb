class CreateContacts < ActiveRecord::Migration[7.2]
  def change
    create_table :contacts do |t|
      t.string :email
      t.string :phone
      t.integer :primary_contact_id
      t.timestamps
    end
  end
end
