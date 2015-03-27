require 'spec_helper'

describe 'Settings' do
  let(:user)    { create :user }
  let(:org)       { create :organization }
  let!(:member) { create :member, organization: org, user: user, role: 'owner' }

  before do
    sign_in user
  end

  subject { page }

  it "root page have settings link" do
    expect(subject).to have_link('Settings')
  end

  context 'page' do
    before do
      click_link 'Settings'
    end

    it 'by default Organization details are shown' do
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
        it_behaves_like 'activatable', 'Organization details'
      end

      describe 'edit' do
        before do
          visit edit_organization_path(org)
        end
        it_behaves_like 'activatable', 'Organization details'
      end
    end

    describe 'customers' do
      describe 'index' do
        before do
          visit customers_path
        end
        it_behaves_like 'activatable', 'Customers'
      end

      describe 'new' do
        before do
          visit new_customer_path
        end
        it_behaves_like 'activatable', 'Customers'
      end

      describe 'edit' do
        let(:customer) { create :customer, organization: org }
        before do
          visit edit_customer_path(customer)
        end
        it_behaves_like 'activatable', 'Customers'
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

    describe 'members' do
      before do
        visit members_path
      end
      it_behaves_like 'activatable', 'Members'
    end
  end
end
