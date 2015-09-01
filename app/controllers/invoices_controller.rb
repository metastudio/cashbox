class InvoicesController < ApplicationController
  layout 'settings'
  before_action :set_invoice, only: [:edit, :show, :update, :destroy]
  before_action :require_organization

  def index
    @invoices = current_organization.invoices.ordered.page(params[:page]).per(10)
  end

  def new
    @invoice = current_organization.invoices.build
  end

  def edit
  end

  def show
  end

  def create
    @invoice = current_organization.invoices.build(invoice_params)

    if @invoice.save
      redirect_to invoices_path, notice: 'Invoice was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to invoices_path, notice: 'Invoice was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @invoice.destroy
    redirect_to invoices_path
  end

  private

  def set_invoice
    @invoice = current_organization.invoices.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:customer_id, :starts_at, :ends_at,
      :currency, :amount, :sent_at, :paid_at,
      invoice_items_attributes: [:id, :customer_id, :amount, :hours, :description, :_destroy])
  end
end
