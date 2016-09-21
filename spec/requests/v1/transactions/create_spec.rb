require 'spec_helper'

describe 'POST /api/organizations/#/transactions' do
  let(:path) { "/api/organizations/#{organization.id}/transactions" }

  let(:bank_account) { create :bank_account, organization: organization }
  let(:amount) { Money.new(10000, bank_account.currency) }
  let(:category) { create :category, :income, organization: organization }
  let(:customer) { create :customer, organization: organization }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }

  context 'unauthenticated' do
    it { post(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    let(:params) {
        {
          transaction: {
            amount: amount,
            category_id: category.id,
            bank_account_id: bank_account.id,
            comment: 'Test Comment',
            comission: 5,
            customer_id: customer.id,
            date: Time.current
          }
        }
      }

    before { post path, params: params, headers: auth_header(owner) }

    it 'returns created transaction' do
      expect(response).to be_success

      expect(json['transaction']).to include(
        'id' => Transaction.last.id,
        'amount' => '95.00',
        'comment' => "Test Comment\nComission: 5₽",
        'comission' => '5'
      )

      expect(json['transaction']['category']).to     include( 'id' => category.id)
      expect(json['transaction']['bank_account']).to include( 'id' => bank_account.id)
      expect(json['transaction']['customer']).to     include( 'id' => customer.id)

      expect(organization.transactions.last.id).to eq Transaction.last.id
      expect(organization.transactions.last.created_by).to eq owner
    end
  end
end
