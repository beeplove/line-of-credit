class Account < ApplicationRecord
  validates :apr, :limit, presence: true

  # TODO: check if the maximum apr and limit is acceptable
  validates :apr, inclusion: { in: 0..79.90 }
  validates :limit, inclusion: { in: 0..1000000 }

  has_many :ledgers

  STATEMENT_PERIOD = 30.days

  # TODO: check if we want to set a maximum amount in one transaction

  def withdraw! amount
    raise ApiExceptions::AccountError::InvalidTransactionAmountError.new("transaction amount is invalid") if amount.to_f <= 0

    amount = amount.to_f
    self.balance += amount
    raise ApiExceptions::AccountError::AccountLimitError.new("transactiona amount is too high") if self.balance > self.limit

    ledger = Ledger.new(account_id: self.id, entry_type: :withdraw, amount: amount, balance: self.balance)
    save_ledger_and_save(ledger)
  end

  # TODO: Check if negative balance is allowed because of high payment
  def deposit! amount
    raise ApiExceptions::AccountError::InvalidTransactionAmountError.new("transaction amount is invalid") if amount.to_f <= 0

    amount = amount.to_f
    self.balance -= amount
    ledger = Ledger.new(account_id: self.id, entry_type: :deposit, amount: amount, balance: self.balance)
    save_ledger_and_save(ledger)
  end

  def save_ledger_and_save ledger
    ActiveRecord::Base.transaction do
      ledgers << ledger
      save!
    end
  end
  private :save_ledger_and_save

  # TODO: Accept any date like param and convert to end_of_day to extend the functionality of this method
  def outstanding_principal time=Time.current
    time = time.end_of_day if time.class == Time

    ledger = ledgers.where("created_at <= ?", time).order("id DESC").limit(1).first
    return 0 if ledger.nil?

    ledger.balance.round(2)
  end

  # TODO:
  #   - Accept any date like param and convert to end_of_day to extend the functionality of this method
  #   - Verify the assumption that interest is calculated for full days, and not charged for franctional day.
  #
  def accumulated_interest time=Time.current
    time = time.end_of_day if time.class == Time

    # Timestamp and balance at the beginning to statement period
    previous_time     = (time - STATEMENT_PERIOD).beginning_of_day
    previous_balance  = outstanding_principal(previous_time)

    interest  = 0
    ledgers   = Ledger.for_account_in_statement_period(id, previous_time, time)

    ledgers.each_with_index do |ledger, i|
      days      = full_days_between_date(ledger.created_at,  previous_time)
      interest += interest_per_day_per_dollar * days * previous_balance

      previous_balance  = ledger.balance
      previous_time     = ledger.created_at
    end

    interest += interest_per_day_per_dollar * full_days_between_date(time, previous_time) * previous_balance

    interest.round(2)
  end

  def full_days_between_date beginning, ending
    ((ending - beginning)/1.day).abs.floor
  end
  private :full_days_between_date

  #
  # TODO: Verify the following assumption
  #   - Account statement period starts on every 30 days as of time account was created
  #
  # on a given day return the statement ending time, for example: if account was created on 1st july, on 5th august 
  # ending_statement_time should return 30th july
  #
  def ending_statement_time time=Time.current
     (self.created_at + (((time - self.created_at)/STATEMENT_PERIOD).floor * STATEMENT_PERIOD)).end_of_day
  end
  private :ending_statement_time

  def statement time=Time.current
    time = Time.current if time.blank?

    if time.class == String
      begin
        time = Time.parse(time)
      rescue ArgumentError
        raise ApiExceptions::AccountError::InvalidStatementDateError.new("statement date is not valid")
      rescue
        raise
      end
    end

    time = ending_statement_time(time)

    json = {}
    json["balance"] = outstanding_principal(time)
    json["interest"] = accumulated_interest(time)
    json["payoff_amount"] = json["balance"] + json["interest"]

    json
  end

  def interest_per_day_per_dollar
    (self.apr/100)/365
  end
  private :interest_per_day_per_dollar
end
