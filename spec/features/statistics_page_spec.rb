require 'rails_helper'

describe 'Statistics' do
  let(:user) { create :user, :with_organization }

  before do
    sign_in user
  end

  subject { page }

  it "root page have settings link" do
    expect(subject).to have_link('Statistics')
  end

  context 'on page' do
    before { click_link 'Statistics' }

    it { expect(page).to have_css('li.active', text: 'Statistics')}
    it { expect(page).to have_link('Statistics')}
    it { expect(page).to have_link('Customers')}
    it { expect(page).to have_link('Bank accounts')}
    it { expect(page).to have_link('Categories')}
    it { expect(page).to have_link('Members')}
    it { expect(page).to have_link('Invoices')}

    it 'Statistics is active by def' do
      expect(page).to have_css('.active', text: 'Income by categories Expense by categories')
      expect(page).to have_css('.active', text: 'Income by customers Expense by customers')
    end

    context 'when switch to other setting' do
      before do
        within '.list-group' do
          click_link 'Categories'
        end
      end
      it 'Categories is active now' do
        expect(page).to have_css('.active', text: 'Categories')
      end
    end
  end
end
