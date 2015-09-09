# == Schema Information
#
# Table name: invoices
#
#  id              :integer          not null, primary key
#  organization_id :integer          not null
#  customer_id     :integer          not null
#  starts_at       :datetime
#  ends_at         :datetime         not null
#  currency        :string           default("USD"), not null
#  amount_cents    :integer          default(0), not null
#  sent_at         :datetime
#  paid_at         :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

require 'spec_helper'

describe Invoice do
  context 'association' do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to have_many(:invoice_items).dependent(:destroy) }
  end

  context 'validation' do
    it { is_expected.to validate_presence_of(:organization) }
    it { is_expected.to validate_presence_of(:ends_at) }
    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_numericality_of(:amount).
      is_greater_than(0).is_less_than_or_equal_to(Dictionaries.money_max) }
    it { is_expected.to validate_inclusion_of(:currency).in_array(Dictionaries.currencies) }
  end
end
