# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/invoices/unpaid' do
  let(:path) { unpaid_api_organization_invoices_path(org) }

  let(:user) { create :user }
  let(:org) { create :organization, with_user: user }
  let!(:unpaid_invoice) { create :invoice, :unpaid, organization: org }
  let!(:paid_invoice)   { create :invoice, :paid,   organization: org }
  let!(:other_invoice)  { create :invoice }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated' do
    before { get path, headers: auth_header(user) }

    it 'returns unpaid invoices of current organization' do
      expect(json['invoices'].size).to eq 1
      expect(json['pagination']).not_to be_blank

      expect(json['invoices'][0]).to include(
        'id'            => unpaid_invoice.id,
        'amount'        => unpaid_invoice.amount.as_json,
        'customer_name' => unpaid_invoice.customer.to_s,
        'starts_at'     => unpaid_invoice.starts_at.as_json,
        'ends_at'       => unpaid_invoice.ends_at.as_json,
        'sent_at'       => unpaid_invoice.sent_at.as_json,
        'paid_at'       => unpaid_invoice.paid_at.as_json,
        'number'        => unpaid_invoice.number,
      )
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { get path, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to be_not_found # we can't find organization with given id for current user
    end
  end
end
