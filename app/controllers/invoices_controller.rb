class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:edit, :show, :update, :destroy]
  before_action :require_organization
  before_action :redirect_for_not_ready_organization
  before_action :find_invoices, only: [:index, :unpaid]

  def index
    @q = current_organization.invoices.ransack(params[:q])
    @q.sorts = ['ends_at desc', 'created_at desc'] if @q.sorts.empty?
    @invoices = @q.result.page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.csv do
        filename = ['invoices', Date.today.strftime("%Y-%m-%d")].join('_')
        send_data @invoices.to_csv, filename: filename, content_type: 'text/csv'
      end
    end
  end

  def unpaid
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

  def find_invoices
    @q = current_organization.invoices.ransack(params[:q])
    @q.sorts = 'ends_at asc' if @q.sorts.empty?
    @invoices = @q.result.page(params[:page]).per(10)
  end

  def invoice_params
    params.require(:invoice).permit([
      :customer_id, :starts_at, :ends_at, :currency, :amount, :sent_at, :paid_at,
      :customer_name, :number, :bank_account_id,
      invoice_items_attributes: %i[id customer_id customer_name amount date hours description _destroy]
    ])
  end
end
