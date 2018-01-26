class CreateLedgers < ActiveRecord::Migration[5.1]
  def change
    create_table :ledgers do |t|
      t.references :account
      t.integer :entry_type, null: false
      t.decimal :amount, precision: 9, scale: 2, null: false

      t.timestamps
    end
  end
end
