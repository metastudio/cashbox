module Api::V1
  class InvoicesController < ApiController

    api :GET, '/invoices', 'Return invoices for current organization'
    def index
      @invoices = current_organization.invoices.includes(:customer)
    end

    api :GET, '/invoices/:id', 'Return invoice'
    def show
      @invoice = current_organization.invoices.includes(:customer).find(params[:id])
    end

    api :POST, '/invoices', 'Create invoice'
    def create
      @invoice = current_organization.invoices.build(invoice_params)

      if @invoice.save
        render :show
      else
        render json: @invoice.errors, status: :unprocessable_entity
      end
    end

    private

    def invoice_params
      params.require(:invoice).permit(:customer_id, :starts_at, :ends_at,
        :currency, :amount, :sent_at, :paid_at, :customer_name, :number,
        invoice_items_attributes: [:id, :customer_id, :customer_name, :amount,
          :date, :hours, :description, :_destroy])
    end
  end
end
