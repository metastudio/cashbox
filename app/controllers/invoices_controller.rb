class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:edit, :update, :destroy]
  before_action :set_organization, only: [:edit, :update, :new, :create, :destroy]

  def new
    @invoice = @organization.invoices.build
  end

  def edit
  end

  def create
    @invoice = @organization.invoices.create(invoice_params)

    if @invoice.save
      redirect_to organization_path(@organization), notice: 'Invoice was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to organization_path(@organization), notice: 'Invoice was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @invoice.destroy
    redirect_to organization_path(@organization)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    def set_organization
      @organization = Organization.find(params[:organization_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invoice_params
      params.require(:invoice).permit(:name, :currency, :description, :balance_cents, :balance_currency)
    end
end
