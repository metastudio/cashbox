require 'spec_helper'

describe 'customers page' do
  let(:user)          { create :user }
  let(:org)           { create :organization, with_user: user }
  let!(:account)      { create :bank_account, organization: org }
  let(:account_name)  { account.name }

  before do
    sign_in user
  end

  subject{ page }

  describe 'pagination', js: true do
    let(:paginated)        { 10 }
    let(:customers_count) { paginated + 10 }

    let!(:customers) { create_list :customer, customers_count, organization: org }

    before do
      visit customers_path
    end

    context 'switch to first page' do
      before do
        within '.pagination' do
          click_on '1'
        end
      end

      it 'lists first page customers' do
        within '.customers' do
          customers.first(paginated).each do |customer|
            expect(subject).to have_selector('td', text: /\A#{customer.name}\z/)
          end
        end
      end

      it 'doesnt list last page customers' do
        within '.customers' do
          customers.last(customers_count - paginated).each do |customer|
            expect(subject).to_not have_selector('td', text: /\A#{customer.name}\z/)
          end
        end
      end
    end

    context 'switch to second page' do
      before do
        within '.pagination' do
          click_on '2'
        end
      end

      it 'doesnt list first page customers' do
        within '.customers' do
          customers.first(paginated).each do |customer|
            expect(subject).to_not have_selector('td', text: /\A#{customer.name}\z/)
          end
        end
      end

      it 'lists last customers' do
        within '.customers' do
          customers.last(customers_count - paginated).each do |customer|
            expect(subject).to have_selector('td', text: /\A#{customer.name}\z/)
          end
        end
      end
    end
  end
end
