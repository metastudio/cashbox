module Api::V1
  class CustomersController < ApiController

    api :GET, '/organizations/:organization_id/customers', 'Return customers for current organization'
    def index
      @customers = current_organization.customers.ordered
    end

    api :GET, '/organizations/:organization_id/customers/for_select', 'Return customers for current organization with select format'
    def for_select
      @customers = current_organization.customers.ordered
    end

  end
end
