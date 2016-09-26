require 'rails_helper'

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
    before { get path, headers: auth_header(owner) }

    it 'returns transactions' do
      expect(response).to be_success

      expect(json[0]).to include(
        'id' => transaction2.id,
        'amount' => money_with_symbol(transaction2.amount),
        'comment' => transaction2.comment
      )
      expect(json[1]).to include(
        'id' => transaction1.id,
        'amount' => money_with_symbol(transaction1.amount),
        'comment' => transaction1.comment
      )
    end
  end

  context 'authenticated as user' do
    before { get path, headers: auth_header(user) }

    it 'returns transactions' do
      expect(response).to be_success

      expect(json[0]).to include(
        'id' => transaction2.id,
        'amount' => money_with_symbol(transaction2.amount),
        'comment' => transaction2.comment
      )
      expect(json[1]).to include(
        'id' => transaction1.id,
        'amount' => money_with_symbol(transaction1.amount),
        'comment' => transaction1.comment
      )
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { get path, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_success
      expect(json).to be_empty
    end
  end
end
