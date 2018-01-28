require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.
#
# Also compared to earlier versions of this generator, there are no longer any
# expectations of assigns and templates rendered. These features have been
# removed from Rails core in Rails 5, but can be added back in via the
# `rails-controller-testing` gem.

RSpec.describe AccountsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Account. As you add validations to Account, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      apr: 35.00,
      limit: 1000
    }
  }

  let(:invalid_attributes) {
    {
      apr: -1.19,
      limit: 1000
    }
  }

  # describe "GET #index" do
  #   it "returns a success response" do
  #     account = Account.create! valid_attributes
  #     get :index, params: {}, session: valid_session
  #     expect(response).to be_success
  #   end
  # end

  # describe "GET #show" do
  #   it "returns a success response" do
  #     account = Account.create! valid_attributes
  #     get :show, params: {id: account.to_param}, session: valid_session
  #     expect(response).to be_success
  #   end
  # end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Account" do

        expect {
          post :create, params: {account: valid_attributes}
        }.to change(Account, :count).by(1)
      end

      it "renders a JSON response with the new account" do

        post :create, params: {account: valid_attributes}
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(account_url(Account.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new account" do

        post :create, params: {account: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe "PUT #withdraw" do
    let(:account) {
      create(:account)
    }

    context "with valid params" do
      it "update balance" do

        post :withdraw, params: { id: account.id, amount: 100.00 }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
        json = JSON.parse(response.body)
        expect(json["balance"].to_f).to eq(100.00)
      end

      it "creates additional record in ledger" do

        expect {
          post :withdraw, params: { id: account.id, amount: 100.00 }
        }.to change(Ledger, :count).by(1)
      end
    end

    context "with invalid params" do
      it "renders a JSON object with errors when amount is not a number" do
        post :withdraw, params: { id: account.id, amount: 'ten dollars' }

        expect(response.content_type).to eq('application/json')
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders a JSON object with errors when try to withdraw too much" do
        post :withdraw, params: { id: account.id, amount: '2000.00' }

        expect(response.content_type).to eq('application/json')
        expect(response).to have_http_status(:unprocessable_entity)
      end

    end
  end

  describe "PUT deposit" do
    let(:account) {
      create(:account)
    }

    context "with valid params" do

      it "update balance" do
        balance = account.balance
        amount = 50.00

        post :deposit, params: { id: account.id, amount: amount }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
        json = JSON.parse(response.body)
        expect(json["balance"].to_f).to eq(-50.00)
      end

      it "creates additional record in ledger" do

        expect {
          post :deposit, params: { id: account.id, amount: 50.00 }
        }.to change(Ledger, :count).by(1)
      end
    end

    context "with invalid params" do
      it "renders a JSON object with errors when amount is not a number" do
        post :deposit, params: { id: account.id, amount: 'fifty dollars' }

        expect(response.content_type).to eq('application/json')
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end


  describe "GET statement" do
    context "without date param after 30 days of account creation" do
      let(:account) {
        travel_to 40.days.ago
        account = create(:account)
        account.withdraw!(500.00)

        travel_back
        account
      }

      it "returns statement summary" do
        get :statement, params: { id: account.id }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
        json = JSON.parse(response.body)
        expect(json["balance"].to_f).to eq(500.00)
        expect(json["interest"].to_f).to eq(14.38)
        expect(json["payoff_amount"].to_f).to eq(514.38)
      end
    end

    context "with date param for account with long history of transactions" do
      let(:now) { Time.current }
      let(:account) {
        travel_to now.ago(100.days)
        account = create(:account)

        travel_to 5.days.after
        account.withdraw!(100.00)

        travel_to 10.days.after
        account.withdraw!(600.00)

        travel_to 8.days.after
        account.deposit!(500.00)

        travel_back
        account
      }

      it "returan statement summary on any given date" do
        get :statement, params: { id: account.id, date: now.ago(69.days).strftime("%Y-%m-%d") }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
        json = JSON.parse(response.body)
        expect(json["balance"].to_f).to eq(200.00)
        expect(json["interest"].to_f).to eq(7.67)
        expect(json["payoff_amount"].to_f).to eq(207.67)
      end
    end
  end

  # describe "PUT #update" do
  #   context "with valid params" do
  #     let(:new_attributes) {
  #       skip("Add a hash of attributes valid for your model")
  #     }

  #     it "updates the requested account" do
  #       account = Account.create! valid_attributes
  #       put :update, params: {id: account.to_param, account: new_attributes}, session: valid_session
  #       account.reload
  #       skip("Add assertions for updated state")
  #     end

  #     it "renders a JSON response with the account" do
  #       account = Account.create! valid_attributes

  #       put :update, params: {id: account.to_param, account: valid_attributes}, session: valid_session
  #       expect(response).to have_http_status(:ok)
  #       expect(response.content_type).to eq('application/json')
  #     end
  #   end

  #   context "with invalid params" do
  #     it "renders a JSON response with errors for the account" do
  #       account = Account.create! valid_attributes

  #       put :update, params: {id: account.to_param, account: invalid_attributes}, session: valid_session
  #       expect(response).to have_http_status(:unprocessable_entity)
  #       expect(response.content_type).to eq('application/json')
  #     end
  #   end
  # end

  # describe "DELETE #destroy" do
  #   it "destroys the requested account" do
  #     account = Account.create! valid_attributes
  #     expect {
  #       delete :destroy, params: {id: account.to_param}, session: valid_session
  #     }.to change(Account, :count).by(-1)
  #   end
  # end

end
