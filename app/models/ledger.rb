class Ledger < ApplicationRecord
  enum entry_type: {
    withdraw: 1,
    deposit: 2
  }

  belongs_to :account
end
