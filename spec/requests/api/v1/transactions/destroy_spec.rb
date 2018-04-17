# frozen_string_literal: true

require 'rails_helper'

describe 'DELETE /api/organizations/#/transactions/#' do
  let(:path) { "/api/organizations/#{organization.id}/transactions/#{transaction.id}" }

  let!(:user) { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:transaction) { create :transaction, :income, :with_customer, organization: organization }

  context 'unauthenticated' do
    it { delete(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as user' do
    before { delete path, headers: auth_header(user) }

    it 'delete transaction' do
      expect(response).to be_success
      expect(response.body).to be_empty

      expect(Transaction.all).to eq []
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { delete path, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_success
      expect(json).to be_empty
    end
  end
end
