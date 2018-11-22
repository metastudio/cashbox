require 'rails_helper'

describe 'PUT /api/organizations/#/bank_accounts/#/sort' do
  let(:path) { "/api/organizations/#{organization.id}/bank_accounts/#{bank_account3.id}/sort" }

  let!(:user) { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:bank_account1) { create :bank_account, organization: organization, position: 1 }
  let!(:bank_account2) { create :bank_account, organization: organization, position: 2 }
  let!(:bank_account3) { create :bank_account, organization: organization, position: 3 }
  let(:params) {
    {
      bank_account: {
        id:       bank_account3.id,
        position: 1,
      }
    }
  }

  context 'unauthenticated' do
    it { put(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as user' do
    before { put path, params: params, headers: auth_header(user) }

    it 'returns updated bank_account' do
      expect(response).to be_success

      bank_account1.reload
      bank_account2.reload
      bank_account3.reload

      expect(json).to include(
        'id'          => bank_account3.id,
        'name'        => bank_account3.name,
        'description' => bank_account3.description,
        'position'    => bank_account3.position,
      )
      expect(bank_account1.position).to eq 2
      expect(bank_account2.position).to eq 3
      expect(bank_account3.position).to eq 1
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { put path, params: params, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_success
      expect(json).to be_empty
    end
  end
end
