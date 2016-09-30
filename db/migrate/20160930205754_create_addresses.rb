class CreateAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :addresses do |t|
      t.string :line1
      t.string :line2
      t.string :subdivision
      t.string :postal_code
      t.integer :customer_id

      t.timestamps
    end
    add_index :addresses, :customer_id
  end
end
