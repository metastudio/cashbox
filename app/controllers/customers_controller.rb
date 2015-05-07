class CustomersController < ApplicationController
  layout 'settings'
  before_action :set_customer, only: [:edit, :update, :destroy]
  before_action :require_organization

  def new
    @customer = current_organization.customers.build
  end

  def edit
  end

  def index
    @customers = current_organization.customers

    respond_to do |format|
      format.html
      format.json { render json: @customers , only: [:id, :name] }
    end
  end

  def create
    @customer = current_organization.customers.build(customer_params)

    if @customer.save
      redirect_to customers_path, notice: 'Customer was successfully created.'
    else
      render action: 'new'
    end
  end

  def autocomplete
    @customers = current_organization.customers.where("name like ?", "%#{query_params[:term]}%")

    respond_to do |format|
      format.json { render json: @customers , :only => [:id, :name] }
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

  private
    def set_customer
      @customer = current_organization.customers.find(params[:id])
    end

    def customer_params
      params.require(:customer).permit(:name)
    end

    def query_params
      params.require(:query).permit(:term)
    end
end
