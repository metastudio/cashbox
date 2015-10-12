require 'spec_helper'

describe 'sidebar' do
  include MoneyHelper
  let(:user)    { create :user }
  let(:org)     { create :organization }
  let!(:member) { create :member, organization: org, user: user, role: 'owner' }
  let(:amount)  { 5000 }
  let!(:account){ create :bank_account, organization: org, balance: amount }

  before do
    sign_in user
    visit root_path
  end

  subject { page }

  context 'accounts' do
    it_behaves_like 'colorizable amount', 'table'
  end

  context 'total' do
    it_behaves_like 'colorizable amount', '#total_balance'

    it 'display exhanged amount' do
      within '#total_balance' do
        expect(page).to have_content(
          money_with_symbol account.balance.exchange_to(org.default_currency))
      end
    end

    it 'display exchange rate' do
      within '#total_balance' do
        expect(page).to have_xpath("//span[contains(concat(' ', @class, ' '), ' exchange-helper ') and contains(@title, '#{Money.default_bank.get_rate(account.currency, org.default_currency).round(4)}')]")
      end
    end

    it 'display total balance in default currency' do
      within '#total_balance' do
        expect(page).to have_content money_with_symbol(account.balance.exchange_to(org.default_currency))
      end
    end
  end

  context 'menu' do
    before do
      visit organization_path(org)
    end

    it 'is shown' do
      within '.list-group' do
        expect(page).to have_css('.active', text: 'Organization details')
        expect(page).to have_content('Bank accounts')
        expect(page).to have_content('Categories')
        expect(page).to have_content('Members')
      end
    end

    describe 'organizations' do
      describe 'index' do
        before do
          visit organizations_path
        end
        it_behaves_like 'activatable', 'Organization details'
      end

      describe 'show' do
        let!(:org2) { create :organization, with_user: user }
        before do
          visit organizations_path
          within "##{dom_id(org2, :switch)}" do
            click_on 'Switch'
          end
        end

        it 'change current_organization' do
          within "#current_organization" do
            expect(page).to have_text org2.name
          end
        end
      end

      describe 'new' do
        before do
          visit new_organization_path
        end
        it_behaves_like 'activatable', 'Organization details'
      end

      describe 'edit' do
        before do
          visit edit_organization_path(org)
        end
        it_behaves_like 'activatable', 'Organization details'
      end
    end

    describe 'categories' do
      describe 'index' do
        before do
          visit categories_path
        end
        it_behaves_like 'activatable', 'Categories'
      end

      describe 'new' do
        before do
          visit new_category_path
        end
        it_behaves_like 'activatable', 'Categories'
      end

      describe 'edit' do
        let(:cat) { create :category, organization: org }
        before do
          visit edit_category_path(cat)
        end
        it_behaves_like 'activatable', 'Categories'
      end
    end

    describe 'members' do
      before do
        visit members_path
      end
      it_behaves_like 'activatable', 'Members'
    end
  end
end
