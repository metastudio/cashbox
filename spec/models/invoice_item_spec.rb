# == Schema Information
#
# Table name: invoice_items
#
#  id           :integer          not null, primary key
#  invoice_id   :integer          not null
#  customer_id  :integer
#  amount_cents :integer          default(0), not null
#  currency     :string           default("USD"), not null
#  hours        :decimal(, )
#  description  :text
#  created_at   :datetime
#  updated_at   :datetime
#

require 'spec_helper'

describe InvoiceItem do
  context 'association' do
    it { is_expected.to belong_to(:invoice) }
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to delegate_method(:organization).to(:invoice) }
  end

  context 'validation' do
    it { is_expected.to validate_presence_of(:invoice) }
    it { is_expected.to validate_numericality_of(:amount).
      is_greater_than(0).is_less_than_or_equal_to(Dictionaries.money_max) }

    context 'customer_name.blank?' do
      let!(:invoice) { create :invoice }

      it 'validates presence of description when true' do
        expect(invoice.invoice_items.build(customer_name: '')).to validate_presence_of(:description)
      end

      it 'does not validates presence of description when false' do
        expect(invoice.invoice_items.build(customer_name: 'customer')).to_not validate_presence_of(:description)
      end
    end
  end
end
