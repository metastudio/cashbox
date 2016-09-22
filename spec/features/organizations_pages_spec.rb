require 'rails_helper'

describe 'organizations pages' do
  include MoneyHelper

  let(:user)   { create :user }
  let(:member) { create :member, user: user }
  let!(:org)   { member.organization }

  before do
    sign_in user
  end

  subject{ page }

  context 'show' do
    context 'depending on permission' do
      before do
        visit organization_path org
      end

      it_behaves_like "organization buttons"
    end
  end

  context 'index' do
    context 'depending on permission' do
      before do
        visit organizations_path
      end

      it_behaves_like "organization buttons"

      context 'when destroying' do
        let(:member) { create :member, user: user, role: 'owner' }

        context 'current organization' do
          before do
            click_on 'Delete'
          end

          it 'doesnt break' do
            expect(page).to have_flash_message('Organization was successfully removed.')
            expect(page).to have_content('No organizations')
          end
        end

        context 'not current organization' do
          let!(:member)  { create :member, user: user, role: 'user' }
          let!(:member2) { create :member, user: user, role: 'owner' }

          before do
            visit organizations_path
            click_on 'Delete'
          end

          it 'doesnt break' do
            expect(page).to have_flash_message('Organization was successfully removed.')
          end
        end
      end
    end
  end
end
