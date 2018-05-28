# frozen_string_literal: true

require 'rails_helper'

describe 'mutation authenticate(email: String!, password: String!): AuthenticatePayload' do
  let(:query) do
    %(
      mutation Authenticate($email: String!, $password: String!) {
        authenticate(email: $email, password: $password) {
          token {
            jwt
          }
        }
      }
    )
  end

  let(:email)     { generate :email }
  let(:password)  { generate :password }
  let!(:user)     { create :user, email: email, password: password }

  let(:variables) { { email: email, password: password } }
  let(:result)    { CashboxSchema.execute(query, variables: variables).to_h }

  it 'returns token for authorized user' do
    expect(result['data']['authenticate']['token']['jwt']).to be_present
    expect(result['errors']).to be_blank
  end

  context 'if email is wrong' do
    let(:variables) { { email: 'wrong@emails', password: password } }

    it 'returns error' do
      expect(result['data']['authenticate']).to eq nil
      expect(result['errors'].first['message']).to eq 'Invalid email or password.'
    end
  end

  context 'if password is wrong' do
    let(:variables) { { email: email, password: 'wrongpassword' } }

    it 'returns error' do
      expect(result['data']['authenticate']).to eq nil
      expect(result['errors'].first['message']).to eq 'Invalid email or password.'
    end
  end

  context 'if user is locked' do
    let!(:user) { create :user, :locked, email: email, password: password }

    it 'returns error' do
      expect(result['data']['authenticate']).to eq nil
      expect(result['errors'].first['message']).to eq 'Your account is locked.'
    end
  end
end
