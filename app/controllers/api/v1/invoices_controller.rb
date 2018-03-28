# frozen_string_literal: true

module Api
  module V1
    class InvoicesController < ApiController

      before_action :authorize_organization, only: %i[index create destroy show]

      api :GET, '/organizations/:organization_id/invoices', 'Return invoices for current organization'
      def index
        @q = @organization.
          invoices.
          ransack(params[:q])

        @q.sorts = 'ends_at desc' if @q.sorts.empty?
        @invoices = @q.result
          .page(params[:page])
          .per(10)
        @pagination = prepare_pagination(@invoices)
        @unpaid_count = @organization.invoices.unpaid.count
      end

      api :GET, '/organizations/:organization_id/invoices/:id', 'Return invoice'
      def show
        @invoice = @organization.invoices.includes(:customer).find(params[:id])
        @invoice_details = @organization
          .bank_accounts
          .visible
          .by_currency(@invoice.currency)
          .first
          .try(:invoice_details)
        @customer_details = @invoice.customer.try(:invoice_details)
      end

      api :POST, '/invoices', 'Create invoice'
      def create
        @invoice = @organization.invoices.build(invoice_params)

        if @invoice.save
          render :show
        else
          render json: @invoice.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @organization.invoices.find(params[:id]).destroy
      end

      private

      def invoice_params
        params.require(:invoice).permit(:customer_id, :starts_at, :ends_at,
          :currency, :amount, :sent_at, :paid_at, :customer_name, :number,
          invoice_items_attributes: [:id, :customer_id, :customer_name, :amount,
            :date, :hours, :description, :_destroy])
      end

      def authorize_organization
        @organization = Organization.find(params[:organization_id])
        authorize @organization, :access?
      end

      def prepare_pagination(collection)
        current = collection.current_page
        total = collection.num_pages
        per_page = collection.limit_value
        {
          current:  current,
          previous: (current > 1 ? (current - 1) : nil),
          next:     (current == total ? nil : (current + 1)),
          per_page: per_page,
          pages:    total,
          count:    collection.total_count
        }
      end
    end
  end
end
