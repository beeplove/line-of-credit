class Ledger < ApplicationRecord
  enum entry_type: {
    withdraw: 1,
    deposit: 2
  }

  belongs_to :account

  scope :for_account_in_statement_period, lambda { |account_id, time_start, time_end|
    where("account_id=? AND created_at >= ? AND created_at <= ?", account_id, time_start, time_end)
  }
end
