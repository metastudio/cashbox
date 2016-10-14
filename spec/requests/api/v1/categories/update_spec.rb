require 'rails_helper'

describe 'PUT /api/organizations/#/categories/#' do
  let(:path) { "/api/organizations/#{organization.id}/categories/#{category.id}" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let!(:category) { create :category, :income, organization: organization }
  let(:params) {
    {
      category: {
        name: 'New Name',
        type: 'Expense'
      }
    }
  }

  context 'unauthenticated' do
    it { put(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { put path, params: params, headers: auth_header(owner) }

    it 'returns updated category' do
      expect(response).to be_success
      category.reload
      expect(json).to include(
        'id' => category.id,
        'name' => 'New Name',
        'type' => 'Expense'
      )
    end
  end

  context 'authenticated as user' do
    before { put path, params: params, headers: auth_header(user) }

    it 'returns updated category' do
      expect(response).to be_success
      category.reload
      expect(json).to include(
        'id' => category.id,
        'name' => 'New Name',
        'type' => 'Expense'
      )
    end

    context 'with wrong params' do
      let(:params) {
        {
          category: {
            name: '',
            type: 'Expense'
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
