#
# TODO: standarize json output
# {
#   "status": "success|error",
#   "data": {
#     "id": 1,
#     "apr": 35.00,
#     "limit": 1000
#   },
#   "error": {
#     "message": "user friendly error message in 1-2 sentence(s)",
#     "code": "application error code (need to maintain a database for error code",
#     "description": "provide further details or a link where more details can be found"
#   }
# }
#

class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :update, :destroy, :withdraw, :deposit, :statement]
  # GET /accounts
  def index
    @accounts = Account.all

    render json: @accounts
  end

  # GET /accounts/1
  def show
    render json: @account
  end

  # POST /accounts
  def create
    @account = Account.new(account_params)

    if @account.save
      render json: @account, status: :created, location: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /accounts/1
  def update
    if @account.update(account_params)
      render json: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # PUT /accounts/1/withdraw
  # params:
  #   amount: amount to withdraw from account
  def withdraw
    if @account.withdraw!(params[:amount])
      render json: @account, status: :ok
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  rescue AccountError::InvalidTransactionAmountError
    render json: @account.errors, status: :unprocessable_entity
  rescue AccountError::AccountLimitError
    render json: @account.errors, status: :unprocessable_entity
  rescue #something went wrong
    render json: @account.errors, status: :unprocessable_entity
  end

  # PUT /accounts/1/deposit
  # params:
  #   amount: amount to deposit to account
  def deposit
    if @account.deposit!(params[:amount])
      render json: @account, status: :ok
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  rescue AccountError::InvalidTransactionAmountError
    render json: @account.errors, status: :unprocessable_entity
  rescue #something went wrong
    render json: @account.errors, status: :unprocessable_entity
  end

  # Last closing statement on a give date
  # GET /accounts/1/statement
  # params
  #   - date: default: current time
  def statement
    if statement = @account.statement(params[:date])
      render json: statement, status: :ok
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  rescue #something went wrong
    render json: @account.errors, status: :unprocessable_entity
  end


  # DELETE /accounts/1
  def destroy
    @account.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def account_params
      params.require(:account).permit(:apr, :limit)
    end
end
