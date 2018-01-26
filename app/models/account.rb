class Account < ApplicationRecord
  validates :apr, :limit, presence: true

  # TODO: check if the maximum apr and limit is acceptable
  validates :apr, inclusion: { in: 0..79.90 }
  validates :limit, inclusion: { in: 0..1000000 }

  has_many :ledgers

  # TODO: check if we want to set a maximum in one transaction

  #
  # TODO: (for withdraw! and deposit!)
  #   - check amount
  #   - check limit before update balance
  #   - refactor to remove duplicate code
  #
  def withdraw! amount
    amount = amount.to_f
    self.balance += amount
    ledger = Ledger.new(account_id: self.id, entry_type: :withdraw, amount: amount)

    ActiveRecord::Base.transaction do
      ledger.save!
      save!
    end
  end

  def deposit! amount
    amount = amount.to_f
    self.balance -= amount
    ledger = Ledger.new(account_id: self.id, entry_type: :deposit, amount: amount)

    ActiveRecord::Base.transaction do
      ledger.save!
      save!
    end
  end
end
