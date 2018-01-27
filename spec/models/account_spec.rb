require 'rails_helper'

RSpec.describe Account, type: :model do

  describe "#withdraw" do
  end

  describe "#deposit" do
  end

  describe "#outstanding_principal" do
    context "brand new account" do
      let(:account) { create(:account) }

      it "should return 0" do
        expect(account.outstanding_principal).to eq(0)
      end
    end

    context "account with ledgers" do
      let(:now) { Time.now }
      let(:account) {
        a = Account.create(apr: 35.00, limit: 1000, created_at: now - 30.days)
        a.withdraw!(500.00)
        a.deposit!(200.00)
        a.ledgers[0].created_at = now - 15.days
        a.ledgers[1].created_at = now - 10.days
        a.ledgers.each { |ledger| ledger.save }
        a
      }

      it "should return outstanding principal for a given day" do
        expect(account.outstanding_principal(now - 25.days)).to eq(300.00)
      end
    end
  end

  describe "#accumulated_interest" do
    context "with one withdraw" do
      let(:now) { Time.now }
      let(:account) { Account.create(apr: 35.00, limit: 1000, created_at: now - 30.days) }

      it "should calculate interest for each day for the outstanding principal of last 30 days" do
        account.withdraw!(500.00)
        account.ledgers[0].created_at = now - 30.days
        account.ledgers.each { |ledger| ledger.save }

        expect(account.accumulated_interest).to eq(14.38)
      end
    end

    context "with multiple transactions" do
      let(:now) { Time.now }
      let(:account) { Account.create(apr: 35.00, limit: 1000, created_at: now - 30.days) }

      it "should consider withdraw and deposit both to calculate interest" do
        account.withdraw!(500.00)
        account.deposit!(200.00)
        account.withdraw!(100.00)
        account.ledgers[0].created_at = now - 30.days
        account.ledgers[1].created_at = now - 15.days
        account.ledgers[2].created_at = now - 5.days

        account.ledgers.each { |ledger| ledger.save }

        expect(account.accumulated_interest).to eq(11.99)        
      end
    end
  end
end
