require 'rails_helper'

describe 'POST /api/users/password' do
  let(:path) { "/api/users/password" }

  let!(:user) { create :user, email: 'email@email.test' }

  context 'unauthenticated' do
    let(:params) {
      {
        user: {
          email: user.email
        }
      }
    }

    before do
      ActionMailer::Base.deliveries = []
      post path, params: params, headers: auth_header(nil)
    end

    it 'send reset password instruction' do
      expect(response).to be_successful
      expect(json).to be_empty

      expect(ActionMailer::Base.deliveries.count).to eq 1
      email = ActionMailer::Base.deliveries.last
      body = email.body.decoded

      expect(email.from).to eq ['no-reply@cashbox.dev']
      expect(email.to).to eq [user.email]
      expect(email.subject).to eq 'Reset password instructions'
      expect(body).to include "Hello email@email.test!"
      expect(body).to include "Someone has requested a link to change your password. You can do this through the link below."
      expect(body).to include "If you didn't request this, please ignore this email."
      expect(body).to include "Your password won't change until you access the link above and create a new one."
      expect(body).to include 'Change my password'
      expect(body).to include '/users/password/edit?reset_password_token='
    end
  end

  context 'with wrong email' do
    let(:params) {
      {
        user: {
          email: 'wrong@email.test'
        }
      }
    }

    before do
      ActionMailer::Base.deliveries = []
      post path, params: params, headers: auth_header(nil)
    end

    it 'returns error' do
      expect(response).to_not be_successful
      expect(json).to include("email" => ["not found"])

      expect(ActionMailer::Base.deliveries.count).to eq 0
    end
  end
end
