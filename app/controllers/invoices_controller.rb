class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:edit, :show, :update, :destroy]
  before_action :require_organization

  def index
    @invoices = current_organization.invoices.ordered.page(params[:page]).per(10)
  end

  def unpaid
    @invoices = current_organization.invoices.unpaid.ordered.page(params[:page]).per(10)
    render :index
  end

  def new
    @invoice = current_organization.invoices.build
  end

  def edit
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: @invoice.pdf_filename, # Excluding ".pdf" extension.
          layout: 'pdf.html.slim',
          print_media_type: true,
          page_size: 'A4',
          orientation: 'Landscape',
          margin: { top: 5, bottom: 5, left: 10, right: 10 },
          show_as_html: params[:debug].present?
      end
    end
  end

  def create
    @invoice = current_organization.invoices.build(invoice_params)

    if @invoice.save
      redirect_to invoice_path(@invoice), notice: 'Invoice was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to invoice_path(@invoice), notice: 'Invoice was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @invoice.destroy
    redirect_to invoices_path, notice: 'Invoice was successfully deleted.'
  end

  private

  def set_invoice
    @invoice = current_organization.invoices.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:customer_id, :starts_at, :ends_at,
      :currency, :amount, :sent_at, :paid_at, :customer_name, :number,
      invoice_items_attributes: [:id, :customer_id, :customer_name, :amount,
        :date, :hours, :description, :_destroy])
  end
end
