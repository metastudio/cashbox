require 'rails_helper'

describe 'PUT /api/users/password' do
  let(:path) { "/api/users/password" }

  let!(:user) { create :user, password: '12345678' }

  before do
    @raw_reset_password_token, db_reset_password_token = Devise.token_generator.generate(User, :reset_password_token)
    user.update(reset_password_token: db_reset_password_token, reset_password_sent_at: Time.current)
  end

  context 'unauthenticated' do
    let(:params) {
      {
        user: {
          password: '87654321',
          password_confirmation: '87654321',
          reset_password_token: @raw_reset_password_token
        }
      }
    }

    before do
      ActionMailer::Base.deliveries = []
      put path, params: params, headers: auth_header(nil)
    end

    it 'updates password' do
      expect(response).to be_success
      expect(json).to be_empty
    end
  end

  context 'without reset password token' do
    let(:params) {
      {
        user: {
          password: '87654321',
          password_confirmation: '87654321'
        }
      }
    }

    before { put path, params: params, headers: auth_header(nil) }

    it 'returns error' do
      expect(response).to_not be_success
      expect(json).to include("reset_password_token" => ["can't be blank"])
    end
  end

  context 'with wrong password confirmation' do
    let(:params) {
      {
        user: {
          password: '87654321',
          password_confirmation: '',
          reset_password_token: @raw_reset_password_token
        }
      }
    }

    before { put path, params: params, headers: auth_header(nil) }

    it 'returns error' do
      expect(response).to_not be_success
      expect(json).to include("password_confirmation" => ["doesn't match Password"])
    end
  end

  context 'with small length password' do
    let(:params) {
      {
        user: {
          password: '87654',
          password_confirmation: '87654',
          reset_password_token: @raw_reset_password_token
        }
      }
    }

    before { put path, params: params, headers: auth_header(nil) }

    it 'returns error' do
      expect(response).to_not be_success
      expect(json).to include("password" => ["is too short (minimum is 6 characters)"])
    end
  end
end
