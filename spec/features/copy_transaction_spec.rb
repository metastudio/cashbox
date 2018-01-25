require 'rails_helper'

describe 'copy transaction', js: true do
  let!(:user)         { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:category)     { create :category, :income, organization: organization }
  let!(:exp_category) { create :category, :expense, organization: organization }
  let(:current_time)  { 1.day.since }
  let!(:account) do
    create :bank_account,
      residue: 99999999,
      organization: organization,
      currency: 'USD'
  end
  let!(:another_account) do
    create :bank_account,
      currency: 'RUB',
      organization: organization,
      residue: 10000
  end
  let!(:transaction) do
    create :transaction,
      category: category,
      organization: organization,
      bank_account: account
  end
  let!(:exp_transaction) do
    create :transaction,
      category: exp_category,
      organization: organization,
      bank_account: account
  end
  let!(:transfer) do
    create :transfer,
      bank_account_id: account.id,
      reference_id: another_account.id,
      from_currency: 'USD',
      to_currency: 'RUB',
      exchange_rate: 0.5
  end

  def beautify(amount)
    if amount > 99999
      amount.to_s.insert(-6, ',').insert(-3, '.')
    else
      amount.to_s.insert(-3, '.')
    end
  end

  before :each do
    sign_in user
  end

  it "copy income transaction" do
    Timecop.travel(current_time) do
      id = transaction.id
      find("#transaction_#{id} .comment").click
      page.has_content?(/(Please review the problems below)/) # wait
      click_on 'Copy'
      expect(page).to have_css('#new_transaction', visible: true)
      within '#new_transaction' do
        expect(page).to have_field('Amount', with: beautify(transaction.amount.cents))
        expect(page).to have_field('Category', with: transaction.category_id)
        expect(page).to have_field('Customer name', with: transaction.customer_id)
        expect(page).to have_field('Bank account', with: transaction.bank_account_id)
        expect(page).to have_field('Comment', with: transaction.comment)
        expect(page).to have_field('Date', with: current_time.strftime('%d/%m/%Y'))
      end
    end
  end

  it 'copy expence transaction' do
    Timecop.travel(current_time) do
      id = exp_transaction.id
      find("#transaction_#{id} .comment").click
      page.has_content?(/(Please review the problems below)/) # wait
      click_on 'Copy'
      expect(page).to have_css('#new_transaction', visible: true)
      within '#new_transaction' do
        expect(page).to have_field('Amount', with: beautify(exp_transaction.amount.cents.abs))
        expect(page).to have_field('Category', with: exp_transaction.category_id)
        expect(page).to have_field('Customer name', with: exp_transaction.customer_id)
        expect(page).to have_field('Bank account', with: exp_transaction.bank_account_id)
        expect(page).to have_field('Comment', with: exp_transaction.comment)
        expect(page).to have_field('Date', with: current_time.strftime('%d/%m/%Y'))
      end
    end
  end

  it 'copy transfer' do
    id = transfer.inc_transaction.id
    find("#transaction_#{id} .comment").click
    page.has_content?(/(Please review the problems below)/) # wait
    click_on 'Copy'
    expect(page).to have_css('#new_transfer_form', visible: true)
    within '#new_transfer_form' do
      expect(page).to have_field('From', with: transfer.out_transaction.bank_account.id)
      expect(page).to have_field('To', with: transfer.inc_transaction.bank_account.id)
      expect(page).to have_field('Amount', with: beautify(transfer.out_transaction.amount.cents.abs))
      expect(page).to have_field('Date', with: exp_transaction.date.strftime('%d/%m/%Y'))
    end
  end
end
