class Account < ApplicationRecord
  validates :apr, :limit, presence: true

  # TODO: check if the maximum apr and limit is acceptable
  validates :apr, inclusion: { in: 0..79.90 }
  validates :limit, inclusion: { in: 0..1000000 }

  has_many :ledgers

  STATEMENT_PERIOD = 30.days

  # TODO: check if we want to set a maximum amount in one transaction

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

    ledger = ledgers.where("created_at < ?", time).order("id DESC").limit(1).first
    return self.balance if ledger.nil?

    ledger.balance
  end

  # TODO: Accept any date like param and convert to midnight
  def accumulated_interest time=Time.now
    time = time.midnight if time.class == Time
    previous_time = time - STATEMENT_PERIOD
    previous_balance = outstanding_principal(previous_time)
    ledgers = Ledger.for_account_in_statement_period(id, time - STATEMENT_PERIOD, time)
    interest = 0

    ledgers.each_with_index do |ledger, i|
      days = (ledger.created_at - previous_time)/1.day
      interest += interest_per_day_per_dollar * days * previous_balance

      previous_balance = ledger.balance
      previous_time = ledger.created_at
    end

    interest += interest_per_day_per_dollar * ((time - previous_time)/1.day) * previous_balance

    interest.round(2)
  end

  def interest_per_day_per_dollar
    (self.apr/100)/365
  end
  private :interest_per_day_per_dollar
end
