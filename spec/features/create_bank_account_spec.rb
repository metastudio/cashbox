require 'spec_helper'

describe 'Create bank account' do
  let(:user) { create :user }
  let(:organization) { create :organization, owner: user }
  let(:account_name) { generate :bank_account_name }
  let(:amount) { 100.55 }
  let(:residue) { 1.55 }


  before do
    sign_in user
    visit organization_path organization
    click_on 'New bank account'
    fill_in 'Name', with: account_name
    fill_in 'Description', with: 'Some description'
    fill_in 'Balance', with: amount
    fill_in 'Residue', with: residue
    click_on 'Create Bank account'
  end

  it { expect(page).to have_content 'Bank account was successfully created' }

  describe 'Initial residue category' do
    subject { organization.categories.first }

    it { expect(subject.name).to eq 'Initial residue' }
    it { expect(subject.type).to eq 'Income' }
  end

  describe 'Initial residue transaction' do
    subject { Transaction.first }

    it { expect(subject.bank_account.name).to eq account_name }
    it { expect(subject.category.name).to eq 'Initial residue' }
    it { expect(subject.amount).to eq 1.55 }
  end
end
