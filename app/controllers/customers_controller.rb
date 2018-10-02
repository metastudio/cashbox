class CustomersController < ApplicationController
  layout 'settings'
  before_action :set_customer, only: [:edit, :update, :destroy]
  before_action :require_organization
  before_action :redirect_for_not_ready_organization

  def index
    @customers = current_organization.customers.ordered.page(params[:page]).per(10)
  end

  def new
    @customer = current_organization.customers.build
  end

  def edit
  end

  def create
    @customer = current_organization.customers.build(customer_params)

    if @customer.save
      redirect_to customers_path, notice: 'Customer was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @customer.update(customer_params)
      redirect_to customers_path, notice: 'Customer was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @customer.destroy
    redirect_to customers_path
  end

  def autocomplete
    @customers = current_organization.customers.with_name(query_params[:term])

    respond_to do |format|
      format.json { render json: @customers.to_json(only: %i[id name]) }
    end
  end

  private

  def set_customer
    @customer = current_organization.customers.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name, :invoice_details)
  end

  def query_params
    params.require(:query).permit(:term)
  end
end
