# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/currencies' do
  let(:path) { api_currencies_path }

  let!(:user) { create :user, password: 'password' }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated' do
    before { get path, headers: auth_header(user) }

    it 'returns currencies' do
      expect(response).to be_success

      expect(json).to eq %w[USD RUB EUR]
    end
  end
end
