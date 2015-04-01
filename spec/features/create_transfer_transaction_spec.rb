require 'spec_helper'

describe 'create transfer transaction', js: true do
  include MoneyHelper
  include ActionView::Helpers::NumberHelper

  let!(:user)         { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:ba1)          { create :bank_account, :with_transactions, organization: organization }
  let!(:ba2)          { create :bank_account, :with_transactions, organization: organization }

  let(:ba1_name)    { ba1.to_s }
  let(:ba2_name)    { ba2.to_s }

  let(:amount)        { 1232.25 }
  let(:amount_str)    { number_to_currency(amount, separator: '.', format: '%n') }
  let(:comission)     { amount }
  let(:comission_str) { amount_str }
  let(:comment)       { 'Test transaction' }


  let(:transactions)  { organization.transactions.where(
    bank_account_id: [ba1.id, ba2.id]) }

  def create_transfer
    visit root_path
    click_on 'Transaction'
    click_on 'Transfer'
    within '#new_transfer_form' do
      fill_in 'transfer[amount]', with: amount_str
      select ba1.name, from: 'transfer[bank_account_id]' if ba1_name.present?
      select ba2.name, from: 'transfer[reference_id]' if ba2_name.present?
      fill_in 'transfer[comission]', with: comission_str
      fill_in 'transfer[comment]',   with: comment
      click_on 'Create'
    end
    page.has_content?(/(Please review the problems below)|(#{amount_str})/) # wait after page rerender
  end

  subject{ create_transfer; page }

  before :each do
    sign_in user
  end

  context "with valid data" do
    it "creates two new transactions" do
      expect{ subject }.to change{ transactions.count }.by(2)
    end

    it "shows created transactions in transactions list" do
      create_transfer
      within ".transactions" do
        expect(page).to have_content(amount_str)
        expect(page).to have_content(
          number_to_currency(amount + comission, separator: '.', format: '%n'))
      end
    end

    it "appends comission to the comment" do
      create_transfer
      within ".transactions" do
        expect(page).to have_content(comment + "\nComission: " + comission.to_s)
      end
    end

    context "recalculates sidebar" do
      let!(:ba1_new_amount) { ba1.balance - Money.new((amount + comission) * 100, ba1.currency) }
      let!(:ba2_new_amount) { ba2.balance + Money.new(amount * 100, ba2.currency) }
      let!(:new_total){ ba1.organization.bank_accounts.total_balance(ba1.currency) -
        Money.new(comission * 100, ba1.currency) }

      it "from account" do
        expect(subject).
          to have_css("#bank_account_#{ba1.id} td.amount",
            text: money_with_symbol(ba1_new_amount))
      end

      it "to account" do
        expect(subject).
          to have_css("#bank_account_#{ba2.id} td.amount",
            text: money_with_symbol(ba2_new_amount))
      end

      it "total balance" do
        create_transfer
        page.find('a.dropdown-toggle[data-target="#dropdown-total"]').click
        expect(page).
          to have_css("#total_balance", text: money_with_symbol(new_total))
      end
    end

    context "when outcome transfer" do
      it "creates transaction with negative amount" do
        expect{ subject }.
          to change{ transactions.where(amount_cents: (amount + comission) * -  100).count }.by(1)
      end
    end

    context "when income transfer" do
      it "creates transaction with positive amount" do
        expect{ subject }.
          to change{ transactions.where(amount_cents: amount * 100).count }.by(1)
      end
    end
  end

  context "without comment" do
    let(:comment) { nil }

    it "create transactions without errors" do
      expect{ subject }.to change{ transactions.count }.by(2)
    end
  end

  context "with not selected FROM" do
    let(:ba1_name) { nil }

    it "doesn't create transactions" do
      expect{ subject }.to_not change{ transactions.count }
    end

    it "shows error for FROM field" do
      expect(subject).to have_inline_error("can't be blank").for_field('transfer_bank_account_id')
    end
  end

  context "with not selected TO" do
    let(:ba2_name) { nil }

    it "doesn't create transactions" do
      expect{ subject }.to_not change{ transactions.count }
    end

    it "shows error for TO field" do
      expect(subject).to have_inline_error("can't be blank").for_field('transfer_reference_id')
    end
  end

  context "transfer to different currency" do
    let!(:ba2) { create :bank_account, organization: organization, currency: "USD" }
    let!(:ba3) { create :bank_account, organization: organization, currency: "USD" }

    before do
      visit root_path
      click_on 'Transaction'
      click_on 'Transfer'
    end

    subject{ page }

    context 'hints' do
      let(:rate) { 5 }
      context 'show' do
        before do
          within '#new_transfer_form' do
            fill_in 'transfer[amount]', with: amount
            select ba1.name, from: 'transfer[bank_account_id]'
            select ba2.name, from: 'transfer[reference_id]'
            fill_in 'transfer[exchange_rate]', with: rate
            find("#transfer_comment").click
          end
        end

        it 'rate' do
          expect(page).to have_css('.help-block',
            text: Money.default_bank.rates["RUB_TO_USD"].round(4) )
        end

        it 'end sum' do
          expect(page).to have_css('.help-block',
            text: (amount * rate).round(4) )
        end
      end

      context 'not show' do
        before do
          within '#new_transfer_form' do
            fill_in 'transfer[amount]', with: amount
            select ba1.name, from: 'transfer[bank_account_id]'
            select ba2.name, from: 'transfer[reference_id]'
            fill_in 'transfer[exchange_rate]', with: rate
            find("#transfer_comment").click
            page.has_css?('help-bock')
            select ba3.name, from: 'transfer[bank_account_id]'
          end
        end

        it 'rate' do
          expect(page).to_not have_css('.help-block',
            text: Money.default_bank.rates["RUB_TO_USD"].round(4) )
        end


        it 'end sum' do
          expect(page).to_not have_css('.help-block',
            text: (amount * rate).round(4) )
        end
      end
    end

    context "when nothing selected" do
      it "doesn't show exchange rate" do
        expect(page).to_not have_field("transfer[exchange_rate]")
      end
    end

    context "when select banks with same currency" do
      before do
        within '#new_transfer_form' do
          select ba2.name, from: 'transfer[bank_account_id]'
          select ba3.name, from: 'transfer[reference_id]'
        end
      end

      it "doesn't show exchange rate" do
        within '#new_transfer_form' do
          expect(page).to_not have_field("transfer[exchange_rate]")
        end
      end
    end

    context "when select banks with different currency" do
      before do
        within '#new_transfer_form' do
          select ba1.name, from: 'transfer[bank_account_id]'
          select ba2.name, from: 'transfer[reference_id]'
        end
      end

      it "show exchange rate" do
        within '#new_transfer_form' do
          expect(page).to have_field("transfer[exchange_rate]")
        end
      end

      context "and select same currency" do
        before do
          within '#new_transfer_form' do
            select ba2.name, from: 'transfer[bank_account_id]'
            select ba3.name, from: 'transfer[reference_id]'
          end
        end

        it "doesn't show exchange rate" do
          within '#new_transfer_form' do
            expect(page).to_not have_field("transfer[exchange_rate]")
          end
        end
      end
    end
  end

  context "when account is hidden" do
    let(:account) { create :bank_account, organization: organization, visible: false}

    before do
      visit root_path
    end

    it "doesn't display account in select" do
      expect(page).to_not have_content(account.to_s)
    end
  end

  context 'switching form' do
    before do
      visit root_path
    end

    context 'has active class for selected' do
      before do
        within '#new_transaction' do
          click_on 'Transaction'
        end
      end

      it 'transaction' do
        within '#new_transaction .dropdown-menu' do
          expect(page).to have_css('li.active', text: 'Transaction')
        end
      end

      context 'when switched' do
        before do
          click_on 'Transfer'
          within '#new_transfer_form' do
            click_on 'Transfer'
          end
        end

        it 'transfer' do
          within '#new_transfer_form .dropdown-menu' do
            expect(page).to have_css('li.active', text: 'Transfer')
          end
        end
      end
    end
  end
end
