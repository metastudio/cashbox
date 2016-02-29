class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:edit, :show, :update, :destroy]
  before_action :require_organization
  before_action :fetch_invoices, only: [:index, :unpaid]
  before_action :order_invoices, only: [:index, :unpaid]

  def index
  end

  def unpaid
    @invoices = @invoices.unpaid
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

  def fetch_invoices
    @invoices = current_organization.invoices.page(params[:page]).per(10)
  end

  def order_invoices
    case params[:order]
    when 'customer'
      @invoices = @invoices.customer_name_asc if params[:direction] == 'asc'
      @invoices = @invoices.customer_name_desc if params[:direction] == 'desc'

    when 'date_range'
      @invoices = @invoices.ends_at_asc if params[:direction] == 'asc'
      @invoices = @invoices.ends_at_desc if params[:direction] == 'desc'

    when 'invoice_total'
      @invoices = @invoices.less_amount if params[:direction] == 'asc'
      @invoices = @invoices.more_amount if params[:direction] == 'desc'

    when 'sent_date'
      @invoices = @invoices.sent_at_asc if params[:direction] == 'asc'
      @invoices = @invoices.sent_at_desc if params[:direction] == 'desc'

    when 'paid_date'
      @invoices = @invoices.paid_at_asc if params[:direction] == 'asc'
      @invoices = @invoices.paid_at_desc if params[:direction] == 'desc'

    else
      @invoices = @invoices.ordered
    end


    return false
  end
end
