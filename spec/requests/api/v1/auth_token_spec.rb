# frozen_string_literal: true

require 'rails_helper'

describe 'POST /api/auth_token' do
  let(:user) { create :user, password: 'password' }

  context 'with valid email and password' do
    it 'returns jwt' do
      post '/api/auth_token', params: { auth: { email: user.email, password: 'password' } }

      expect(response).to be_success
      expect(json['jwt']).to be_present
    end
  end

  context 'with wrong password' do
    it 'responds with an error' do
      post '/api/auth_token', params: { auth: { email: user.email, password: 'wrongpassword' } }

      expect(response).to be_unauthorized
      expect(json['error']).to eq 'Invalid email or password.'
    end
  end

  context 'with locked user' do
    let(:user) { create :user, password: 'password', locked_at: Time.current }

    it 'responds with an error' do
      post '/api/auth_token', params: { auth: { email: user.email, password: 'password' } }

      expect(response).to be_unauthorized
      expect(json['error']).to eq 'Your account is locked.'
    end
  end

  context 'with not existed user' do
    it 'responds with an error' do
      post '/api/auth_token', params: { auth: { email: 'some@test.mail', password: 'password' } }

      expect(response).to be_unauthorized
      expect(json['error']).to eq 'Invalid email or password.'
    end
  end
end
