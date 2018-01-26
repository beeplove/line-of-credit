class AddBalanceToLedger < ActiveRecord::Migration[5.1]
  def change
    add_column :ledgers, :balance, :decimal, precision: 9, scale: 2, null: false, after: :amount
  end
end
