# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/invoices/#' do
  let(:path) { api_organization_invoice_path(org, invoice) }

  let(:user) { create :user }
  let(:org) { create :organization, with_user: user }

  let(:invoice) { create :invoice, organization: org }
  let(:customer) { create :customer }
  let!(:invoice_item) { create :invoice_item, customer: customer, invoice: invoice, date: Date.current }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated' do
    before { get path, headers: auth_header(user) }

    context 'user belongs to invoice\'s organization' do
      it 'returns invoice' do
        expect(response).to be_successful

        expect(json).to include(
          'id'                     => invoice.id,
          'paid_at'                => invoice.paid_at.as_json,
          'ends_at'                => invoice.ends_at.as_json,
          'has_income_transaction' => false,
          'number'                 => invoice.number,
          'currency'               => invoice.currency,
          'amount'                 => invoice.amount.as_json,
          'customer_name'          => invoice.customer.to_s,
          'customer_id'            => invoice.customer.id,
        )

        expect(json['invoice_items'].size).to eq 1
        expect(json['invoice_items'][0]).to include(
          'description'   => invoice_item.description,
          'hours'         => invoice_item.hours.to_s,
          'amount'        => invoice_item.amount.as_json,
          'currency'      => invoice_item.currency,
          'customer_id'   => invoice_item.customer_id,
          'customer_name' => invoice_item.customer.to_s,
          'date'          => invoice_item.date.as_json,
        )
      end
    end

    context "user doesn't belong to invoice's org" do
      let!(:invoice) { create :invoice }

      it 'returns error' do
        expect(response).to be_not_found
        expect(json).to be_empty
      end
    end
  end
end
