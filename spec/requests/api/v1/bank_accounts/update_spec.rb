require 'rails_helper'

describe 'PUT /api/organizations/#/bank_accounts/#' do
  let(:path) { "/api/organizations/#{organization.id}/bank_accounts/#{bank_account.id}" }

  let!(:user) { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:bank_account) { create :bank_account, organization: organization }
  let(:params) {
    {
      bank_account: {
        name:        'New Name',
        description: 'New Description'
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
      bank_account.reload
      expect(json).to include(
        'id'          => bank_account.id,
        'name'        => 'New Name',
        'description' => 'New Description'
      )
    end

    context 'with wrong params' do
      let(:params) {
        {
          bank_account: {
            name: ''
          }
        }
      }

      it 'returns error' do
        expect(response).to_not be_success
        expect(json).to include "name" => ["can't be blank"]
      end
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
