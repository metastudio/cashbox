require 'spec_helper'

describe 'Create invoice', js: true do
  let(:user)          { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:customer)     { create :customer, organization: organization}
  let(:amount_str)    { '1,232.23' }

  before do
    sign_in user
    visit invoices_path
  end

  context 'Create invoice without items' do
    before do
      click_on 'New Invoice'
      select2 customer.name, css: '#s2id_invoice_customer_name', search: true
      fill_in 'Ends at', with: Time.now.strftime('%d/%m/%Y')
      fill_in 'invoice[amount]', with: amount_str
      click_on 'Create Invoice'
    end

    it { expect(page).to have_content 'Invoice was successfully created' }
  end

  context 'Create invoice with items' do
    before do
      click_on 'New Invoice'
      select2 customer.name, css: '#s2id_invoice_customer_name', search: true
      fill_in 'Ends at', with: Time.now.strftime('%d/%m/%Y')
      fill_in 'invoice[amount]', with: amount_str
      click_on 'Add item'
      find('#invoice .nested-fields input.nested-amount').set(amount_str)
      find('#invoice .nested-fields input.nested-hours').set('1.1')
      find('#invoice .nested-fields textarea.nested-description').set('Description')
      click_on 'Create Invoice'
    end

    it { expect(page).to have_content 'Invoice was successfully created' }
  end

end
