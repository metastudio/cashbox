require 'spec_helper'

describe 'Create invoice', js: true do
  include MoneyHelper

  let(:user)          { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:customer)     { create :customer, organization: organization }
  let(:amount)        { Money.new(1000) }

  before do
    sign_in user
    visit invoices_path
  end

  context 'Create invoice without items' do
    before do
      click_on 'New Invoice'
      select2 customer.name, css: '#s2id_invoice_customer_name', search: true
      fill_in 'Ends at', with: Time.now.strftime('%d/%m/%Y')
      page.execute_script("$(\"invoice[amount]\").val('');")
      fill_in 'invoice[amount]', with: amount
      click_on 'Create Invoice'
    end

    it { expect(page).to have_content 'Invoice was successfully created' }
    it { expect(page).to have_content customer.name }
    it { expect(page).to have_css('td', text: money_with_symbol(amount)) }
    it { expect(page).to have_link 'Show' }
    it { expect(page).to have_link 'Edit' }
    it { expect(page).to have_link 'Destroy' }
  end

  context 'Create invoice with items' do
    let(:first_item_amount) { Money.new(1100) }
    let(:last_item_amount)  { Money.new(1200) }
    let(:total_amount)      { first_item_amount + last_item_amount }

    before do
      click_on 'New Invoice'
      select2 customer.name, css: '#s2id_invoice_customer_name', search: true
      fill_in 'Ends at', with: Time.now.strftime('%d/%m/%Y')
      click_on 'Add item'
      first('#invoice .nested-fields input.nested-amount').set(first_item_amount)
      first('#invoice .nested-fields input.nested-hours').set('1.1')
      first('#invoice .nested-fields textarea.nested-description').set('First Nested Description')
      click_on 'Add item'
      within all('#invoice .nested-fields').last do
        find('input.nested-amount').set(last_item_amount)
        find('input.nested-hours').set('2.1')
        find('textarea.nested-description').set('Last Nested Description')
      end
      click_on 'Create Invoice'
      click_on 'Show'
    end

    it { expect(page).to have_css('td', text: money_with_symbol(total_amount)) }
    it { expect(page).to have_css('td', text: money_with_symbol(first_item_amount)) }
    it { expect(page).to have_css('td', text: money_with_symbol(last_item_amount)) }
    it { expect(page).to have_content '1.1' }
    it { expect(page).to have_content '2.1' }
    it { expect(page).to have_content 'First Nested Description' }
    it { expect(page).to have_content 'Last Nested Description' }
  end

  context 'set invoice amount disabled then add invoice items' do
    before do
      click_on 'New Invoice'
      click_on 'Add item'
    end

    it { expect(page).to have_css('#invoice_amount:disabled') }
  end
end
