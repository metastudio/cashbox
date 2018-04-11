# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/invoices' do
  let(:path) { api_organization_invoices_path(org) }

  let(:user) { create :user }
  let(:org) { create :organization, with_user: user }
  let!(:invoice1) { create :invoice, organization: org }
  let!(:invoice2) { create :invoice }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated' do
    before { get path, headers: auth_header(user) }

    it 'returns invoices of current organization' do
      expect(json['invoices'].size).to eq 1
      expect(json['pagination']).not_to be_blank

      expect(json['invoices'][0]).to include(
        'id'            => invoice1.id,
        'amount'        => invoice1.amount.as_json,
        'customer_name' => invoice1.customer.to_s,
        'starts_at'     => invoice1.starts_at.as_json,
        'ends_at'       => invoice1.ends_at.as_json,
        'sent_at'       => invoice1.sent_at.as_json,
        'paid_at'       => invoice1.paid_at.as_json,
        'number'        => invoice1.number,
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
