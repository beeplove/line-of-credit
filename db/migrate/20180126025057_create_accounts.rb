class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.decimal :apr, precision: 5, scale: 2
      t.integer :limit

      t.timestamps
    end
  end
end
