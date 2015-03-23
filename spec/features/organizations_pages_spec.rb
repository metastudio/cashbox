require 'spec_helper'

describe 'organizations pages' do
  include MoneyHelper

  let(:user)   { create :user }
  let(:member) { create :member, user: user }
  let!(:org)   { member.organization }

  before do
    sign_in user
  end

  subject{ page }

  context 'show' do
    context 'depending on permission' do
      before do
        visit organization_path org
      end

      it_behaves_like "organization buttons"
    end

    context 'bank accounts list' do
      let!(:ba)  { create :bank_account, organization: org, balance: amount }

      before do
        visit organization_path org
      end

      it_behaves_like "colorizable amount", '.bank-accounts'
    end
  end

  context 'index' do
    context 'depending on permission' do
      before do
        visit organizations_path
      end

      it_behaves_like "organization buttons"
    end
  end
end
