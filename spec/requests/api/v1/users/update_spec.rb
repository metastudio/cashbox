# frozen_string_literal: true

require 'rails_helper'

describe 'PUT /api/users/#' do
  let(:path) { "/api/users/#{user.id}" }

  let(:password) { 'password' }
  let(:newpassword) { 'newpassword' }
  let(:newemail) { 'newemail@example.com' }
  let(:user) { create :user, password: password }
  let(:params) do
    {
      user: {
        email: newemail,
        current_password: password,
        password: newpassword,
        password_confirmation: newpassword
      }
    }
  end

  context 'unauthenticated' do
    it { put(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as user' do
    before { put path, params: params, headers: auth_header(user) }

    it 'returns updated transaction' do
      expect(response).to be_success
      expect(json).to include(
        'id' => user.id,
        'email' => newemail
      )
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { put path, params: params, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to be_forbidden
    end
  end
end
