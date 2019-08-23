require 'rails_helper'

describe 'POST /api/organizations/#/categories' do
  let(:path) { "/api/organizations/#{organization.id}/categories" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let(:params) {
    {
      category: {
        name: 'Test',
        type: 'Income'
      }
    }
  }

  context 'unauthenticated' do
    it { post(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { post path, params: params, headers: auth_header(owner) }

    it 'returns created category' do
      expect(response).to be_successful

      expect(json).to include(
        'id' => Category.last.id,
        'name' => 'Test',
        'type' => 'Income'
      )
      expect(organization.categories.last.id).to eq Category.last.id
    end

    context 'with wrong params' do
      let(:params) {
        { category: {
            name: '',
            type: ''
          }
        }
      }

      it 'returns error' do
        expect(response).to_not be_successful

        expect(json).to include "name" => ["can't be blank"]
        expect(json).to include "type" => ["can't be blank", " is not a valid category type"]
      end
    end
  end

  context 'authenticated as user' do
    before { post path, params: params, headers: auth_header(user) }

    it 'returns created category' do
      expect(response).to be_successful

      expect(json).to include(
        'id' => Category.last.id,
        'name' => 'Test',
        'type' => 'Income'
      )
      expect(organization.categories.last.id).to eq Category.last.id
    end

    context 'with wrong params' do
      let(:params) {
        { category: {
            name: '',
            type: ''
          }
        }
      }

      it 'returns error' do
        expect(response).to_not be_successful

        expect(json).to include "name" => ["can't be blank"]
        expect(json).to include "type" => ["can't be blank", " is not a valid category type"]
      end
    end
  end
end
