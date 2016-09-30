class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|
      t.string :username
      t.string :password
      t.integer :customer_id

      t.timestamps
    end
    add_index :accounts, :username
    add_index :accounts, :customer_id
  end
end
