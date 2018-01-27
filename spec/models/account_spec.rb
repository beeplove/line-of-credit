require 'rails_helper'

RSpec.describe Account, type: :model do

  describe "#withdraw" do
  end

  describe "#deposit" do
  end

  describe "#outstanding_principal" do
    context "brand new account" do
      let(:now) { Time.now }
      let(:account) {
        a = Account.create(apr: 35.00, limit: 1000)
      }

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
      let(:now) { Time.now }
      let(:account) {
        a = Account.create(apr: 35.00, limit: 1000, created_at: now - 30.days)
        a.withdraw!(500.00)
        a.ledgers[0].created_at = now - 30.days
        a.ledgers.each { |ledger| ledger.save }
        a
      }

    it "should calculate interest for each day for the outstanding principal of last 30 days" do
      expect(account.accumulated_interest).to eq(14.38)
    end
  end
end
