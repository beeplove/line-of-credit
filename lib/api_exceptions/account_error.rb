module ApiExceptions  
  class AccountError < ApiExceptions::BaseException
    class InvalidTransactionAmountError < ApiExceptions::AccountError
    end
  end
end