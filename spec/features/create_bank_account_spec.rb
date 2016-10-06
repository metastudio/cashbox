require 'rails_helper'

describe 'Create bank account' do
  let(:member_owner) { create :member, :owner }
  let(:organization) { member_owner.organization }
  let(:account_name) { generate :bank_account_name }
  let(:residue) { 100.55 }


  before do
    sign_in member_owner.user
    visit bank_accounts_path
    click_on 'New bank account'
    fill_in 'Name', with: account_name
    fill_in 'Description', with: 'Some description'
    fill_in 'Invoice details', with: 'Test Invoice Details'
    fill_in 'Residue', with: residue
    click_on 'Create Bank account'
  end

  it 'shows created bank account' do
    expect(page).to have_content 'Bank account was successfully created'
    expect(page).to have_content account_name
    expect(page).to have_content 'Test Invoice Details'
  end


  describe 'Initial residue transaction' do
    subject { Transaction.first }

    it do
      expect(subject.bank_account.name).to eq account_name
      expect(subject.transaction_type).to eq 'Residue'
      expect(subject.amount).to eq Money.new(10055, 'USD')
    end
  end

  context 'balance' do
    subject { BankAccount.second.balance.to_f }

    it { expect(subject).to eq residue }
  end
end
