require 'rails_helper'

describe 'DELETE /api/organizations/#/categories/#' do
  let(:path) { "/api/organizations/#{organization.id}/categories/#{category.id}" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let!(:category) { create :category, organization: organization }

  context 'unauthenticated' do
    it { delete(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { delete path, headers: auth_header(owner) }

    it 'delete category' do
      expect(response).to be_successful
      expect(json).to include(
        'id' => category.id
      )

      category.reload
      expect(category.deleted_at).to_not eq nil
    end
  end

  context 'authenticated as user' do
    before { delete path, headers: auth_header(user) }

    it 'delete category' do
      expect(response).to be_successful
      expect(json).to include(
        'id' => category.id
      )

      category.reload
      expect(category.deleted_at).to_not eq nil
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { delete path, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_successful
      expect(json).to be_empty

      category.reload
      expect(category.deleted_at).to eq nil
    end
  end
end
