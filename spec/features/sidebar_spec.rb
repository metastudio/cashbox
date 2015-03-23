require 'spec_helper'

describe 'sidebar' do
  let(:user)    { create :user }
  let(:org)     { create :organization }
  let!(:member) { create :member, organization: org, user: user, role: 'owner' }

  before do
    sign_in user
  end

  subject { page }

  context "right classes for accounts" do
    let!(:account) { create :bank_account, organization: org, balance: 50000 }
    let!(:account_empty){ create :bank_account, organization: org, balance: 0 }
    before do
      visit root_path
    end

    it "for positive" do
      within '#sidebar .accounts .positive' do
        expect(page).to have_content account.to_s
      end
    end

    it "for empty" do
      within '#sidebar .accounts .empty' do
        expect(page).to have_content account_empty.to_s
      end
    end
  end

  context 'menu' do
    before do
      visit organization_path(org)
    end

    it 'is shown' do
      within '.list-group' do
        expect(page).to have_content('Organizations')
        expect(page).to have_css('.active', 'Bank accounts')
        expect(page).to have_content('Categories')
        expect(page).to have_content('Members')
      end
    end

    describe 'organizations' do
      describe 'index' do
        before do
          visit organizations_path
        end
        it_behaves_like 'activatable', 'Organizations'
      end

      describe 'show' do
        let!(:org2) { create :organization, with_user: user }
        before do
          visit organizations_path
          click_on org2.name
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
        it_behaves_like 'activatable', 'Organizations'
      end

      describe 'edit' do
        before do
          visit edit_organization_path(org)
        end
        it_behaves_like 'activatable', 'Organizations'
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
