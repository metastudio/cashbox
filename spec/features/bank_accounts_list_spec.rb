require 'spec_helper'

describe 'Bank accounts list' do
  let(:user) { create :user }
  let(:org)  { create :organization, with_user: user }
  let!(:ba)  { create :bank_account, organization: org, residue: amount }

  before do
    sign_in user
    visit bank_accounts_path
  end

  after { Capybara.reset_sessions! }

  it_behaves_like "colorizable amount", '.bank-accounts'
end
