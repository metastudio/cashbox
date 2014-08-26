require 'spec_helper'

describe 'category page' do
  let(:user)         { create :user }
  let(:organization) { create :organization, with_user: user }
  let(:category1)     { create :category, organization: organization }
  let(:category2)     { create :category, organization: organization }
  let(:account)      { create :bank_account, organization: organization}
  let(:comment1)      { generate :transaction_comment }
  let(:comment2)      { generate :transaction_comment }
  let(:comment3)      { generate :transaction_comment }
  let!(:transaction1) { create :transaction, bank_account: account, category: category1, comment: comment1 }
  let!(:transaction2) { create :transaction, bank_account: account, category: category2, comment: comment2 }
  let(:amount)        { 150.66 }
  let(:account_name)  { account.name }

  before do
    sign_in user
    visit category_path category1
  end

  subject{ page }

  it { expect(subject).to have_content category1.name }
  it { expect(subject).to have_content comment1 }
  it { expect(subject).not_to have_content comment2 }

  describe 'create transaction', js: true do
    before do
      within '#new_transaction' do
        fill_in 'transaction[amount]', with: amount
        select account_name, from: 'transaction[bank_account_id]'
        fill_in 'transaction[comment]', with: comment3
        click_on 'Create Transaction'
      end
    end
    context 'valid params' do
      it "shows created transaction in transactions list" do
        within ".transactions" do
          expect(page).to have_content(amount)
        end
      end
    end

    context 'invalid params' do
      let(:account_name) { 'Account' }
      it { expect(page).to have_content('Please review the problems below') }
      it { expect(page).to have_inline_error("can't be blank").for_field_name('transaction[bank_account_id]') }
    end
  end
end
