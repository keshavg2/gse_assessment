class CreateContacts < ActiveRecord::Migration[7.2]
  def change
    create_table :contacts do |t|
      t.string :email
      t.string :phone
      t.references :primary, foreign_key: { to_table: :contacts }, index: true
      t.timestamps
    end
  end
end
