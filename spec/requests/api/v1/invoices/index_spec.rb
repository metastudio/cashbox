# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/invoices' do
  let(:path) { api_organization_invoices_path(org) }
  let(:headers) { auth_header(user) }

  let(:org) { create :organization }
  let(:user) { create :user, organization: org }

  let!(:invoice1) { create :invoice, organization: org }
  let!(:invoice2) { create :invoice }

  before do
    get path, headers: headers
  end

  context 'authenticated' do
    it 'returns invoices of current organization' do
      expect(json_body.invoices.size).to eq 1
      expect(json_body.pagination).not_to be_blank

      invoice_json = json_body.invoices.first
      expect(invoice_json).to be_short_invoice_json(invoice1)
    end
  end

  context 'unauthenticated' do
    let(:headers) { {} }

    it 'returns Unauthorized error' do
      expect(response).to be_unauthorized
    end
  end

  context 'authenticated as a user not associated with the organization' do
    let!(:user) { create :user }

    it 'returns Not Found error' do
      expect(response).to be_not_found
    end
  end
end
