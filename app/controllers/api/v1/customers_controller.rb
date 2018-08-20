# frozen_string_literal: true

module Api::V1
  class CustomersController < BaseOrganizationController
    before_action :set_customer, only: %i[show update destroy]

    def_param_group :customer do
      param :customer, Hash, required: true, action_aware: true do
        param :name, String, 'Name'
        param :invoice_details, String, 'Invoice Details'
      end
    end

    api :GET, '/organizations/:organization_id/customers', 'Return customers for current organization'
    def index
      @customers = current_organization.customers.ordered
    end

    api :GET, '/organizations/:organization_id/customers/:id', 'Return customer'
    def show
    end

    api :POST, '/organizations/:organization_id/customers', 'Create customer'
    param_group :customer, CustomersController
    def create
      @customer = current_organization.customers.build customer_params
      if @customer.save
        render :show
      else
        render json: @customer.errors, status: :unprocessable_entity
      end
    end

    api :PUT, '/organizations/:organization_id/customers/:id', 'Update customer'
    param_group :customer, CustomersController
    def update
      if @customer.update(customer_params)
        render :show
      else
        render json: @customer.errors, status: :unprocessable_entity
      end
    end

    api :DELETE, '/organizations/:organization_id/customers/:id', 'Destroy customer'
    def destroy
      @customer.destroy
      render :show
    end

    private

    def set_customer
      @customer = current_organization.customers.find(params[:id])
    end

    def customer_params
      params.fetch(:customer, {}).permit(:name, :invoice_details)
    end
  end
end
