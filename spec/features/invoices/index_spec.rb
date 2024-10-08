require 'rails_helper'

describe 'invoices index page' do
  let(:user) { create :user }
  let!(:org) { create :organization, with_user: user }

  before do
    sign_in user
  end

  include_context 'invoices pagination'
  it_behaves_like 'paginateable' do
    let!(:list)      { create_list(:invoice, invoices_count, organization: org); org.invoices.order(ends_at: :desc, created_at: :desc) }
    let(:list_class) { '.invoices' }
    let(:list_page)  { invoices_path }
  end

  context "show only current organization's invoices" do
    let!(:invoice) { create :invoice, organization: org, number: '0000#01' }
    let!(:other_invoice) { create :invoice, organization: create(:organization) }

    before do
      visit invoices_path
    end

    it "invoice index page displays current organization's invoices" do
      expect(page).to have_content(invoice.customer_name)
      expect(page).to_not have_content(other_invoice.customer_name)
    end

    it 'has column Number and displays correct invoice number' do
      expect(page).to have_css('th#invoice_number_col_head', text: 'Number')
      expect(page).to have_css('td', text: '0000#01')
    end
  end

  context 'colorize invoice' do
    let!(:overdue_invoice) { create :invoice, organization: org, sent_at: Date.current - 16.days }
    let!(:paid_invoice) { create :invoice, organization: org, paid_at: Date.current }

    before do
      visit invoices_path
    end

    it "overdue invoice has class 'overdue'" do
      within '#invoices_list' do
        expect(page).to have_css("tr.invoice.overdue##{dom_id(overdue_invoice)}")
      end
    end

    it "paid invoice has class 'paid'" do
      within '#invoices_list' do
        expect(page).to have_css("tr.invoice.paid##{dom_id(paid_invoice)}")
      end
    end
  end

  context 'complete invoice', js: true do
    let!(:account)  { create :bank_account, organization: org }
    let!(:category) { create :category, :income, organization: org }
    let!(:wrong_category) { create :category, :expense, organization: org }
    let!(:wrong_account)  { create :bank_account, organization: org, currency: 'USD' }
    let!(:invoice)  { create :invoice, organization: org, amount: 500 }
    let(:comission) { Money.new(100, invoice.currency) }

    def create_transaction_by_invoice
      visit invoice_path(invoice)
      click_on 'Complete Invoice'
      within '#new_transaction' do
        select category.name, from: 'transaction[category_id]'
        select account.name, from: 'transaction[bank_account_id]'
        fill_in 'transaction[comission]', with: comission
        fill_in 'transaction[comment]', with: 'TestComment'
      end
      click_on 'Create'
      page.has_content?(/(Please review the problems below)/) # wait after page rerender
    end

    it 'for has valid attributes and hint with calculated total amount' do
      visit invoice_path(invoice)
      click_on 'Complete Invoice'
      within '#new_transaction' do
        select category.name, from: 'transaction[category_id]'
        select account.name, from: 'transaction[bank_account_id]'
        fill_in 'transaction[comission]', with: comission
        fill_in 'transaction[comment]', with: 'TestComment'
      end
      expect(page).to_not have_select('Category', with_options: [wrong_category.name])
      expect(page).to_not have_select('Bank Account', with_options: [wrong_account.name])
      expect(page).to have_field('Comission', with: comission)
      expect(page).to have_content("Total amount: #{invoice.amount - comission}" )
    end

    context "invoice has assigned bank account" do
      let!(:invoice) { create :invoice, organization: org, bank_account: account }
      let!(:account_next)  { create :bank_account, organization: org }

      before do
        visit invoice_path(invoice)
        click_on 'Complete Invoice'
      end

      it 'displays transaction window with pre-filled bank account' do
        expect(page).to have_css('select#transaction_bank_account_id')
        expect(page).to have_css('select#transaction_bank_account_id option[selected]', text: account.name)
        select account_next.name
        expect(page).to have_css('select#transaction_bank_account_id', text: account_next.name)
      end
    end

    subject{ create_transaction_by_invoice; page }

    context 'update invoice paid_at after create transaction' do
      before do
        create_transaction_by_invoice
        visit invoices_path
      end

      it 'invoice paid_at must present' do
        invoice.reload
        within "tr##{dom_id(invoice)} td.paid_at" do
          expect(page).to have_content(I18n.l(invoice.paid_at))
        end
        expect(invoice.paid_at).not_to be_nil
      end
    end

    context 'with valid data' do
      it 'creates a new transaction' do
        expect{ subject }.to change(Transaction, :count).by(1)
      end

      context 'check transaction' do
        before do
          create_transaction_by_invoice
          visit root_path
        end

        it 'shows created transaction in transactions list' do
          expect(page).to have_content(money_with_symbol(invoice.amount - comission))
          expect(page).to have_content(category.name)
          expect(page).to have_content(account.name)
          expect(page).to have_content('TestComment')
          expect(page).to have_content(I18n.l(Date.current))
        end
      end
    end
  end

  describe 'Invoices filtering' do
    let!(:unpaid) { create :invoice, organization: org }
    let!(:paid) { create :invoice, :paid, organization: org }

    before do
      visit invoices_path
    end

    it "displays all invoices" do
      expect(page).to have_css "#invoice_#{unpaid.id}"
      expect(page).to have_css "#invoice_#{paid.id}"
    end

    context 'select unpaid only' do
      before do
        click_link "Unpaid (1)"
      end

      it "displays unpaid invoices only" do
        expect(page).to have_css "#invoice_#{unpaid.id}"
        expect(page).to have_no_css "#invoice_#{paid.id}"
      end
    end
  end

  describe "Debtor customers" do
    let!(:invoice1) { create :invoice, organization: org, currency: 'EUR', amount_cents: 3000 }
    let!(:invoice2) { create :invoice, organization: org, currency: 'RUB', amount_cents: 10000 }
    let(:invoice1_money) { Money.new(3000, 'EUR') }
    let(:invoice2_money) { Money.new(10000, 'RUB') }
    before do
      Money.default_currency = :usd
      visit invoices_path
    end

    it "displays debtors" do
      within "#debtor_customer_#{invoice1.customer_id}" do
        expect(page).to have_content "#{invoice1.customer.name}: #{invoice1_money.format} (#{invoice1_money.exchange_to('USD').format}"
      end

      within "#debtor_customer_#{invoice2.customer_id}" do
        expect(page).to have_content "#{invoice2.customer.name}: #{invoice2_money.format} (#{invoice2_money.exchange_to('USD').format}"
      end
    end

    it "display all debtors sum" do
      expect(page).to have_content "#{invoice1_money.format} (#{invoice1_money.exchange_to('USD').format} );"
      expect(page).to have_content "#{invoice2_money.format} (#{invoice2_money.exchange_to('USD').format} );"
    end

    it "display total debtors sum" do
      expect(page).to have_content "Total: #{(invoice1_money.exchange_to('USD') + invoice2_money.exchange_to('USD')).format}"
    end

    context 'there are no unpaid invoices' do
      let!(:invoice1) { create :invoice, :paid, organization: org, currency: 'EUR', amount_cents: 3000 }
      let!(:invoice2) { create :invoice, :paid, organization: org, currency: 'RUB', amount_cents: 10000 }
      it { expect(page).to have_content 'No debtors at the moment.' }
    end
  end

  describe 'Invoices sorting' do
    context 'default order' do
      let!(:invoice1) { create :invoice, customer_name: 'Adam', organization: org, ends_at: 2.days.ago.to_date }
      let!(:invoice2) { create :invoice, customer_name: 'Eve', organization: org, ends_at: 1.day.ago.to_date }

      before do
        visit invoices_path
      end

      it "sorts by date range desc" do
        within all('#invoices_list tr.invoice').first do
          expect(page).to have_content 'Eve'
        end
        within all('#invoices_list tr.invoice').last do
          expect(page).to have_content 'Adam'
        end
      end
    end

    context 'by customer name' do
      let!(:invoice1) { create :invoice, customer_name: 'Adam', organization: org }
      let!(:invoice2) { create :invoice, customer_name: 'Eve', organization: org }

      before do
        visit invoices_path
        within "#customer_col_head" do
          click_link 'Customer'
        end
      end

      it "sorts by customer name asc" do
        within all('#invoices_list tr.invoice').first do
          expect(page).to have_content 'Adam'
        end
        within all('#invoices_list tr.invoice').last do
          expect(page).to have_content 'Eve'
        end
      end

      context 'sort desc' do
        before do
          within "#customer_col_head" do
            click_link 'Customer'
          end
        end

        it "sorts by customer name desc" do
          within all('#invoices_list tr.invoice').first do
            expect(page).to have_content 'Eve'
          end
          within all('#invoices_list tr.invoice').last do
            expect(page).to have_content 'Adam'
          end
        end
      end
    end

    context 'by date range' do
      let!(:invoice1) { create :invoice, customer_name: 'Adam', organization: org, ends_at: 1.day.ago.to_date }
      let!(:invoice2) { create :invoice, customer_name: 'Eve', organization: org, ends_at: 2.days.ago.to_date }

      before do
        visit invoices_path
        click_link 'Date range'
      end

      it "sorts by date range asc" do
        within all('#invoices_list tr.invoice').first do
          expect(page).to have_content 'Eve'
        end
        within all('#invoices_list tr.invoice').last do
          expect(page).to have_content 'Adam'
        end
      end

      context 'sort desc' do
        before do
          click_link 'Date range'
        end

        it "sorts by date range desc" do
          within all('#invoices_list tr.invoice').first do
            expect(page).to have_content 'Adam'
          end
          within all('#invoices_list tr.invoice').last do
            expect(page).to have_content 'Eve'
          end
        end
      end
    end

    context 'by invoice total' do
      let!(:invoice1) { create :invoice, customer_name: 'Adam', organization: org, amount_cents: 20 }
      let!(:invoice2) { create :invoice, customer_name: 'Eve', organization: org, amount_cents: 10 }

      before do
        visit invoices_path
        click_link 'Invoice total'
      end

      it "sorts by invoice total asc" do
        within all('#invoices_list tr.invoice').first do
          expect(page).to have_content 'Eve'
        end
        within all('#invoices_list tr.invoice').last do
          expect(page).to have_content 'Adam'
        end
      end

      context 'sort desc' do
        before do
          click_link 'Invoice total'
        end

        it "sorts by invoice total desc" do
          within all('#invoices_list tr.invoice').first do
            expect(page).to have_content 'Adam'
          end
          within all('#invoices_list tr.invoice').last do
            expect(page).to have_content 'Eve'
          end
        end
      end
    end

    context 'by sent date' do
      let!(:invoice1) { create :invoice, customer_name: 'Adam', organization: org, sent_at: 2.days.ago.to_date }
      let!(:invoice2) { create :invoice, customer_name: 'Eve', organization: org, sent_at: 1.day.ago.to_date }

      before do
        visit invoices_path
        click_link 'Sent date'
      end

      it "sorts by sent date asc" do
        within all('#invoices_list tr.invoice').first do
          expect(page).to have_content 'Adam'
        end
        within all('#invoices_list tr.invoice').last do
          expect(page).to have_content 'Eve'
        end
      end

      context 'sort desc' do
        before do
          click_link 'Sent date'
        end

        it "sorts by sent date desc" do
          within all('#invoices_list tr.invoice').first do
            expect(page).to have_content 'Eve'
          end
          within all('#invoices_list tr.invoice').last do
            expect(page).to have_content 'Adam'
          end
        end
      end
    end

    context 'by paid date' do
      let!(:invoice1) { create :invoice, customer_name: 'Adam', organization: org, paid_at: 2.days.ago.to_date }
      let!(:invoice2) { create :invoice, customer_name: 'Eve', organization: org, paid_at: 1.day.ago.to_date }

      before do
        visit invoices_path
        click_link 'Paid date'
      end

      it "sorts by paid date asc" do
        within all('#invoices_list tr.invoice').first do
          expect(page).to have_content 'Adam'
        end
        within all('#invoices_list tr.invoice').last do
          expect(page).to have_content 'Eve'
        end
      end

      context 'sort desc' do
        before do
          click_link 'Paid date'
        end

        it "sorts by paid date desc" do
          within all('#invoices_list tr.invoice').first do
            expect(page).to have_content 'Eve'
          end
          within all('#invoices_list tr.invoice').last do
            expect(page).to have_content 'Adam'
          end
        end
      end
    end
  end

  describe 'GET #index.csv' do
    let!(:invoice) { create :invoice, organization: org, number: '0000#01' }
    let!(:unpaid) { create :invoice, organization: org }
    let!(:paid) { create :invoice, :paid, organization: org }

    before do
      visit invoices_path
    end
    
    context "when user export all his invoices" do
      before do
        click_link 'Download as .CSV'
      end

      it 'responds with CSV format' do
        expect(page.response_headers['Content-Type']).to eq 'text/csv'
        expect(page.body).to eq <<~CSV
          Number,Currency,Amount,Customer,Starts at,Ends at,Sent at,Paid at
          #{invoice.number},#{invoice.currency},#{invoice.amount},#{invoice.customer},#{invoice.starts_at},#{invoice.ends_at},#{invoice.sent_at},#{invoice.paid_at}
          #{unpaid.number},#{unpaid.currency},#{unpaid.amount},#{unpaid.customer},#{unpaid.starts_at},#{unpaid.ends_at},#{unpaid.sent_at},#{unpaid.paid_at}
          #{paid.number},#{paid.currency},#{paid.amount},#{paid.customer},#{paid.starts_at},#{paid.ends_at},#{paid.sent_at},#{paid.paid_at}
        CSV
      end
    end

    context "when user export only unpaid invoices" do
      before do
        click_link 'Unpaid (2)'
      end

      it 'responds with CSV format' do
        expect(page).to have_link('Download as .CSV', href: '/invoices.csv?q%5Bunpaid%5D=true')
        click_link 'Download as .CSV'
        expect(page.response_headers['Content-Type']).to eq 'text/csv'
        expect(page.body).to eq <<~CSV
          Number,Currency,Amount,Customer,Starts at,Ends at,Sent at,Paid at
          #{invoice.number},#{invoice.currency},#{invoice.amount},#{invoice.customer},#{invoice.starts_at},#{invoice.ends_at},#{invoice.sent_at},#{invoice.paid_at}
          #{unpaid.number},#{unpaid.currency},#{unpaid.amount},#{unpaid.customer},#{unpaid.starts_at},#{unpaid.ends_at},#{unpaid.sent_at},#{unpaid.paid_at}
        CSV
      end
    end

    it 'has link to export invoices in csv format' do
      expect(page).to have_link('Download as .CSV', href: '/invoices.csv')
    end
  end
end
