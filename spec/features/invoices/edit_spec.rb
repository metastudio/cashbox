require 'spec_helper'

describe 'Edit invoice', js: true do
  let(:user)          { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:customer)     { create :customer, organization: organization }
  let!(:invoice)      { create :invoice, organization: organization, customer: customer }

  before do
    sign_in user
    visit invoice_path(invoice)
  end

  context 'Edit invoice' do
    before do
      click_on 'Edit'
    end

    it { expect(page).to have_content 'Edit invoice' }
    it { expect(page).to have_content 'Invoice items' }
    it { expect(page).to have_link 'Add item' }

    context 'Add invoice item row' do
      before do
        click_on 'Add item'
      end

      it { expect(page).to have_css 'tr.nested-fields' }

      context 'And delete row' do
        before do
          click_on 'delete'
        end

        it { expect(page).to_not have_css 'tr.nested-fields' }
      end
    end
  end
end
