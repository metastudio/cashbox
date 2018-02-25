require 'rails_helper'

describe 'GET /api/invoices#' do
  let(:path) { "/api/invoices/#{invoice.id}" }

  let(:user) { create :user }
  let!(:org) { create :organization, with_user: user }
  let(:invoice) { create :invoice, organization: org }
  let(:customer) { create :customer }
  let!(:invoice_item) { create :invoice_item, customer: customer, invoice: invoice, date: Date.today  }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated' do
    before { get path, headers: auth_header(user) }

    context "user belongs to invoice's organization" do
      it 'returns invoice' do
        expect(response).to be_success

        expect(json).to include(
          'id' => invoice.id,
          'paid_at' => invoice.paid_at,
          'ends_at' => invoice.ends_at.iso8601,
          'income_transaction_presence' => invoice.income_transaction.present?,
          'number' => invoice.number,
          'currency' => invoice.currency,
          'amount' => money_with_symbol(invoice.amount),
          'customer_name' => invoice.customer.to_s
        )

        expect(json['invoice_items'][0]).to include(
          'description' => invoice_item.description,
          'hours' => invoice_item.hours.to_s,
          'amount' => money_with_symbol(invoice_item.amount),
          'currency' => invoice_item.currency,
          'customer_to_s' => invoice_item.customer.to_s,
          'date' => invoice_item.date.iso8601
        )

      end
    end

    context "user doesn't belong to invoice's org" do
      let!(:invoice) { create :invoice }

      it 'returns error' do
        expect(response).to_not be_success
        expect(json).to be_empty
      end
    end
  end
end