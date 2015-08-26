# == Schema Information
#
# Table name: invoice_items
#
#  id              :integer          not null, primary key
#  invoice_id      :integer          not null
#  customer_id     :integer
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           default("USD"), not null
#  hours           :decimal(, )
#  description     :text
#  created_at      :datetime
#  updated_at      :datetime
#

require 'spec_helper'

describe InvoiceItem do
  context 'association' do
    it { is_expected.to belong_to(:invoice) }
    it { is_expected.to belong_to(:customer) }
  end

  context 'validation' do
    it { is_expected.to validate_presence_of(:invoice) }
    it { is_expected.to validate_numericality_of(:amount).
      is_greater_than(0).is_less_than_or_equal_to(Dictionaries.money_max) }

    context 'when customer and description are empty' do
      let!(:invoice_item) { build :invoice_item, customer: nil, description: '' }

      subject { invoice_item }

      it 'is invalid' do
        expect(subject).to be_invalid
        expect(subject.errors_on(:base)).to include('Customer or Description must be present')
      end
    end
  end
end
