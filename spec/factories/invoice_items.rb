# frozen_string_literal: true

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
#  date         :date
#

FactoryBot.define do
  sequence(:invoice_item_description) { |n| "Invoice item description #{n}" }

  factory :invoice_item do
    invoice
    customer_name
    amount      Money.from_amount(5.00)
    hours       0.5
    description { generate :invoice_item_description }
  end
end
