require 'spec_helper'

describe 'category hiding' do
  include MoneyRails::ActionViewExtension

  let(:user)        { create :user, :with_organization }
  let(:organization){ user.organizations.first }
  let(:category)    { create :category, organization: organization }
  let!(:transaction){ create :transaction, category: category, organization: organization  }

  before do
    sign_in user
  end

  subject { page }

  context "when category is shown" do
    before do
      visit root_path
    end

    it "shows ordinary transaction" do
      expect(subject).
        to have_css(".transaction.success#transaction_#{transaction.id}",
          text: humanized_money_with_symbol(transaction.amount))
    end

    it "select box include category" do
      within "#transaction_category_id" do
        expect(subject).
          to have_content(category.name)
      end
    end
  end

  context "when hide category" do
    before do
      visit categories_path
      click_on 'Hide'
      visit root_path
    end

    it "shows hidden transaction" do
      expect(subject).
        to have_css(".transaction.bg-warning#transaction_#{transaction.id}",
          text: humanized_money_with_symbol(transaction.amount))
    end

    it "select box not include category" do
      expect(subject).
        to_not have_css("#transaction_category_id", text: category.name)
    end
  end
end
