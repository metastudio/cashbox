require 'spec_helper'

describe 'categories page' do
  let(:user)          { create :user }
  let(:org)           { create :organization, with_user: user }
  let!(:account)      { create :bank_account, organization: org }
  let(:account_name)  { account.name }

  before do
    sign_in user
  end

  subject{ page }

  describe "pagination", js: true do
    let(:paginated)        { 10 }
    let(:categories_count) { paginated + 10 }

    let!(:categories) { create_list :category, categories_count, organization: org }

    before do
      visit categories_path
    end

    context "switch to first page" do
      before do
        within '.pagination' do
          click_on '1'
        end
      end

      it "lists first page categories" do
        within ".categories" do
          categories.first(paginated).each do |category|
            expect(subject).to have_selector('td', text: /\A#{category.name}\z/)
          end
        end
      end

      it "doesnt list last page categories" do
        within ".categories" do
          categories.last(categories_count - paginated).each do |category|
            expect(subject).to_not have_selector('td', text: /\A#{category.name}\z/)
          end
        end
      end
    end

    context "switch to second page" do
      before do
        within '.pagination' do
          click_on '2'
        end
      end

      it "doesnt list first page categories" do
        within ".categories" do
          categories.first(paginated).each do |category|
            expect(subject).to_not have_selector('td', text: /\A#{category.name}\z/)
          end
        end
      end

      it "lists last categories" do
        within ".categories" do
          categories.last(categories_count - paginated).each do |category|
            expect(subject).to have_selector('td', text: /\A#{category.name}\z/)
          end
        end
      end
    end
  end

end
