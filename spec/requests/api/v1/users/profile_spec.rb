require 'rails_helper'

describe 'GET /api/users/:id/update_profile' do
  context 'when unauthenticated' do
    let(:path) { '/api/users/1/update_profile' }
    it 'return 401' do
      put(path)
      expect(response).to(be_unauthorized)
      expect(response.code).to eq('401')
    end
  end

  context 'when authenticated' do
    let(:full_name) { 'Woo Cheng' }
    let(:phone) { '+15555555555' }

    context 'and user_id is correct' do
      let(:user) { create :user, password: 'password' }
      let(:path) { "/api/users/#{user.id}/update_profile" }
      before do
        put(
          path,
          headers: auth_header(user),
          params: {
            user: {
              full_name:          full_name,
              profile_attributes: { phone_number: phone }
            }
          }
        )
      end

      it 'return 200' do
        expect(response).to be_successful
        expect(response.code).to eq('200')
      end

      it 'update profile fullname and phone number' do
        changed_user = User.find(user.id)
        expect(changed_user.full_name).to eq(full_name)
        expect(changed_user.profile.phone_number).to eq(phone)
      end
    end

    context 'and user is incorrect' do
      let(:user) { create :user, password: 'password' }
      let(:user_2) { create :user, password: 'password' }
      let(:path) { "/api/users/#{user_2.id}/update_profile" }

      before do
        put(
          path,
          headers: auth_header(user),
          params: {
            user: {
              full_name:          full_name,
              profile_attributes: { phone_number: phone }
            }
          }
        )
      end

      it 'return 403' do
        expect(response).to be_forbidden
        expect(response.code).to eq('403')
      end
    end

    context 'and params is incorrect' do
      let(:user) { create :user, password: 'password' }
      let(:path) { "/api/users/#{user.id}/update_profile" }
      let(:full_name) { nil }
      let(:phone) { '666-666' }

      before do
        put(
          path,
          headers: auth_header(user),
          params: {
            user: {
              full_name:          full_name,
              profile_attributes: { phone_number: phone }
            }
          }
        )
      end

      it 'returns error' do
        expect(response).to_not be_successful
        expect(response.code).to eq('422')
        expect(json).to include 'full_name' => ["can't be blank"]
        expect(json).to include 'profile' => { 'phone_number' => ['is an invalid number'] }
      end
    end
  end
end
