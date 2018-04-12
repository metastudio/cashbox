# frozen_string_literal: true

class Api::V1::InvoicesController < Api::V1::BaseOrganizationController
  after_action :verify_authorized

  before_action :set_invoice, only: %i[show destroy]

  api :GET, '/organizations/:organization_id/invoices', 'Return invoices for organization'
  def index
    authorize :invoice

    @q = policy_scope(Invoice).ransack(params[:q])
    @q.sorts = 'ends_at desc' if @q.sorts.empty?
    @invoices = @q.result.includes(:customer).page(params[:page])
  end

  api :GET, '/organizations/:organization_id/invoices/unpaid', 'Return unpaid invoices for organization'
  def unpaid
    authorize :invoice

    @q = policy_scope(Invoice).unpaid.ransack(params[:q])
    @q.sorts = 'ends_at desc' if @q.sorts.empty?
    @invoices = @q.result.includes(:customer).page(params[:page])

    render :index
  end

  api :GET, '/organizations/:organization_id/invoices/unpaid/count', 'Return number of unpaid invoices for organization'
  def unpaid_count
    authorize :invoice

    @unpaid_count = policy_scope(Invoice).unpaid.count
  end

  api :GET, '/organizations/:organization_id/invoices/:id', 'Return invoice'
  def show
  end

  api :POST, '/invoices', 'Create invoice'
  def create
    @invoice = current_organization.invoices.build
    authorize @invoice

    @invoice.attributes = permitted_attributes(@invoice)

    if @invoice.save
      render :show
    else
      render json: @invoice.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @invoice.destroy
      render :show
    else
      render json: @invoice.errors, status: :unprocessable_entity
    end
  end

  private

  def set_invoice
    @invoice = current_organization.invoices.find(params[:id])
    authorize @invoice
  end

  def invoice_params
    params.require(:invoice).permit(
      :customer_id, :starts_at, :ends_at, :currency, :amount, :sent_at,
      :paid_at, :customer_name, :number,
      invoice_items_attributes: %i[
        id customer_id customer_name amount
        date hours description _destroy
      ]
    )
  end
end
