class Account < ApplicationRecord
  validates :apr, :limit, presence: true

  # TODO: check if the maximum apr and limit is acceptable
  validates :apr, inclusion: { in: 0..79.90 }
  validates :limit, inclusion: { in: 0..1000000 }

  # TODO: check if we want to set a maximum in one transaction


  # TODO:
  #   - check limit
  #   - check amount
  def withdraw! amount
  end

  def deposit! amount

  end
end
