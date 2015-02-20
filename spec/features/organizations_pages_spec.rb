require 'spec_helper'

describe 'organizations pages' do
  let(:user)   { create :user }
  let(:member) { member }
  let!(:org)   { member.organization }

  before do
    sign_in user
  end

  subject{ page }

  context 'show' do
    before do
      visit organization_path org
    end

    it_behaves_like "organization buttons permissions"
  end

  context 'lists bank accounts' do
    let!(:member) { create :member, :user, user: user }

    context 'pagination' do
      let(:paginated)      { 10 }
      let(:ba_count)       { paginated + 10 }
      let!(:bank_accounts) { create_list :bank_account, ba_count,
        organization: org }

      before { visit organization_path org }

      it "lists first page bank accounts" do
        within ".bank-accounts" do
          bank_accounts.last(paginated).each do |ba|
            expect(subject).to have_css('td', text: ba.name)
          end
        end
      end

      it "doesnt list last page bank_accounts" do
        within ".bank-accounts" do
          bank_accounts.first(ba_count - paginated).each do |ba|
            expect(subject).to_not have_css('td', text: ba.name)
          end
        end
      end

      context "switch to second page" do
        before do
          within '.pagination' do
            click_on '2'
          end
        end

        it "doesnt list first page bank_accounts" do
          within ".bank-accounts" do
            bank_accounts.last(paginated).each do |ba|
              expect(subject).to_not have_css('td', text: ba.name)
            end
          end
        end

        it "lists last bank_accounts" do
          within ".bank-accounts" do
            bank_accounts.first(ba_count - paginated).each do |ba|
              expect(subject).to have_css('td', text: ba.name)
            end
          end
        end
      end
    end
  end

  context 'index' do
    before do
      visit organizations_path
    end

    it_behaves_like "organization buttons permissions"
  end
end
