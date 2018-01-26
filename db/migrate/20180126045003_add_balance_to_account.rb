class AddBalanceToAccount < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :balance, :decimal, precision: 9, scale: 2, default: 0, after: :limit
  end
end
