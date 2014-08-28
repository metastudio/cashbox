require 'spec_helper'

describe 'Create bank account' do
  let(:user) { create :user }
  let(:organization) { create :organization, owner: user }
  let(:account_name) { generate :bank_account_name }
  let(:residue) { 100.55 }


  before do
    sign_in user
    visit organization_path organization
    click_on 'New bank account'
    fill_in 'Name', with: account_name
    fill_in 'Description', with: 'Some description'
    fill_in 'Residue', with: residue
    click_on 'Create Bank account'
  end

  it { expect(page).to have_content 'Bank account was successfully created' }


  describe 'Initial residue transaction' do
    subject { Transaction.first }

    it { expect(subject.bank_account.name).to eq account_name }
    it { expect(subject.transaction_type).to eq 'Residue' }
    it { expect(subject.amount).to eq 100.55 }
  end

  context 'balance' do
    subject { BankAccount.first.balance }

    it { expect(subject).to eq residue }
  end
end
