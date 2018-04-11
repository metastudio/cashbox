# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/invoices/unpaid/count' do
  let(:path) { unpaid_count_api_organization_invoices_path(org) }

  let(:user) { create :user }
  let(:org) { create :organization, with_user: user }
  let!(:unpaid_invoice1) { create :invoice, :unpaid, organization: org }
  let!(:unpaid_invoice2) { create :invoice, :unpaid, organization: org }
  let!(:unpaid_invoice3) { create :invoice, :unpaid, organization: org }
  let!(:paid_invoice)   { create :invoice, :paid,   organization: org }
  let!(:other_invoice)  { create :invoice }

  let(:unpaid_invoices) { [unpaid_invoice1, unpaid_invoice2, unpaid_invoice3] }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated' do
    before { get path, headers: auth_header(user) }

    it 'returns number of unpaid invoices for current organization' do
      expect(json['unpaid_count']).to eq unpaid_invoices.size
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
