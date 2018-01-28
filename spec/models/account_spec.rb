require 'rails_helper'

RSpec.describe Account, type: :model do

  describe "#withdraw" do
  end

  describe "#deposit" do
  end

  describe "#outstanding_principal" do
    context "brand new account" do
      let(:account) {
        travel_to 30.days.ago
        account = create(:account)
        travel_back
        account
      }

      it "should return 0" do
        expect(account.outstanding_principal).to eq(0)
      end
    end

    context "account with ledgers" do
      let(:account) {
        travel_to 30.days.ago
        account = create(:account)
        travel_to 15.days.after
        account.withdraw!(500.00)
        travel_to 5.days.after
        account.deposit!(200.00)
        travel_back
        account
      }

      it "should return outstanding principal for a given day" do
        expect(account.outstanding_principal(25.days.ago)).to eq(0)
        expect(account.outstanding_principal(15.days.ago)).to eq(500.00)
        expect(account.outstanding_principal(5.days.ago)).to eq(300.00)
        expect(account.outstanding_principal).to eq(300.00)
      end
    end
  end

  describe "#accumulated_interest" do
    context "with one withdraw" do
      let(:account) {
        travel_to 30.days.ago
        account = create(:account)
        account.withdraw!(500.00)

        travel_back
        account
      }

      it "should calculate interest for each day for the outstanding principal of last 30 days" do
        expect(account.accumulated_interest).to eq(14.38)
      end
    end

    context "with multiple transactions" do
      let(:account) {
        travel_to 30.days.ago
        account = create(:account)
        account.withdraw!(500.00)

        travel_to 15.days.after
        account.deposit!(200.00)

        travel_to 10.days.after
        account.withdraw!(100.00)

        travel_back
        account
      }

      it "should consider withdraw and deposit both to calculate interest" do
        expect(account.accumulated_interest).to eq(11.99)        
      end
    end
  end
end
