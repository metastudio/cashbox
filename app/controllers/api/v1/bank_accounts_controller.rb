module Api::V1
  class BankAccountsController < ApiController

    api :GET, '/organizations/:organization_id/bank_accounts', 'Return bank accounts for current organization'
    def index
      @bank_accounts = current_organization.bank_accounts
    end

    api :GET, '/organizations/:organization_id/bank_accounts/for_select', 'Return bank accounts for current organization with select format'
    def for_select
      @bank_accounts = current_organization.bank_accounts
    end

  end
end
