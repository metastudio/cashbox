require 'spec_helper'

describe 'organizations pages' do
  let(:user)   { create :user }
  let(:member) { member }
  let!(:org)   { member.organization }

  before do
    sign_in user
  end

  subject{ page }

  context 'show' do
    before do
      visit organization_path org
    end

    it_behaves_like "organization buttons permissions"
  end

  context 'index' do
    before do
      visit organizations_path
    end

    it_behaves_like "organization buttons permissions"
  end
end
