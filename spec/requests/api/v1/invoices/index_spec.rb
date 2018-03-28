require 'rails_helper'

describe 'GET api/invoices' do
  let(:path) { "/api/organizations/#{org.id}/invoices" }

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
      expect(json[0]).to include(
        'id' => invoice1.id,
        'amount' => money_with_symbol(invoice1.amount),
        'customer_name' => invoice1.customer.to_s
      )
    end

    it 'does not return other invoices' do
      expect(json.size).to eq 1
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { get path, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to be_forbidden
    end
  end
end
