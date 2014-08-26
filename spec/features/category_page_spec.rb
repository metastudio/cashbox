require 'spec_helper'

describe 'category page' do
  let(:user)         { create :user }
  let(:organization) { create :organization, with_user: user }
  let(:category)     { create :category, organization: organization }
  let(:account)      { create :bank_account, organization: organization}
  let!(:transaction1) { create :transaction, bank_account: account, category: category, comment: 'transaction 1' }
  let!(:transaction2) { create :transaction, bank_account: account, category: category, comment: 'transaction 2' }

  before do
    sign_in user
    visit category_path category
  end

  subject{ page }

  it { expect(subject).to have_content category.name }
  it { expect(subject).to have_content 'transaction 1' }
  it { expect(subject).to have_content 'transaction 2' }

end
