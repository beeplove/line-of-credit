module ApiExceptions  
  class AccountError < ApiExceptions::BaseException
    class InvalidTransactionAmountError < ApiExceptions::AccountError
    end

    class AccountLimitError < ApiExceptions::AccountError
    end

    class InvalidStatementDateError < ApiExceptions::AccountError
    end

  end
end
