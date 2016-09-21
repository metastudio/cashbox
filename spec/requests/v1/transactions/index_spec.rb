require 'spec_helper'

describe 'GET /api/organizations/#/transactions' do
  let(:path) { "/api/organizations/#{organization.id}/transactions" }

  let(:bank_account) { create :bank_account, organization: organization }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let!(:transaction1) { create :transaction, :income, :with_customer, bank_account: bank_account }
  let!(:transaction2) { create :transaction, :expense, :with_customer, bank_account: bank_account }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { get path, headers: auth_header(user) }

    it 'returns transactions' do
      expect(response).to be_success

      expect(json['transactions'].size).to eq 2
      expect(json['transactions'][0]).to include(
        'id' => transaction2.id,
        'amount' => transaction2.amount.to_s,
        'comment' => transaction2.comment
      )
      expect(json['transactions'][1]).to include(
        'id' => transaction1.id,
        'amount' => transaction1.amount.to_s,
        'comment' => transaction1.comment
      )
    end
  end
end
