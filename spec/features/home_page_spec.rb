require 'spec_helper'

describe 'Home page' do
  let(:user) { create :user }
  let!(:org)  { create :organization, with_user: user }

  before do
    sign_in user
    visit root_path
  end

  after { Capybara.reset_sessions! }

  context 'when no transactions' do
    context 'show alert' do
      it { expect(page).to have_css('.alert.alert-warning', text: 'This is default page, you will see all transactions from your organization') }

      it 'contains link to bank account creation' do
        within '.alert.alert-warning' do
          expect(page).to have_link('add bank accounts')
        end
      end
    end
  end
end
