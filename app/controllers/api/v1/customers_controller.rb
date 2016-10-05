module Api::V1
  class CustomersController < ApiController

    api :GET, '/organizations/:organization_id/customers', 'Return customers for current organization'
    def index
      @customers = current_organization.customers.ordered
    end

  end
end
