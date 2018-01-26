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
    ledger = Ledger.new(account_id: self.id, entry_type: :withdraw, amount: amount, balance: self.balance)

    ActiveRecord::Base.transaction do
      ledger.save!
      save!
    end
  end

  def deposit! amount
    amount = amount.to_f
    self.balance -= amount
    ledger = Ledger.new(account_id: self.id, entry_type: :deposit, amount: amount, balance: self.balance)

    ActiveRecord::Base.transaction do
      ledger.save!
      save!
    end
  end

  # TODO: Accept any date like param and convert to midnight
  def outstanding_principal time=Time.now
    time = time.midnight if time.class == Time

    return self.balance if self.ledgers.empty?

    last = self.ledgers.where("created_at < ?", time).order("id DESC").limit(1).first
    return self.balance if last.nil?

    last.balance

    # SELECT * FROM ledgers WHERE account_id=#{id} AND created_at < #{time} ORDER BY id DESC LIMIT 1

  end
end
