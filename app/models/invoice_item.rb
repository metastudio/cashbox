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

class InvoiceItem < ActiveRecord::Base
  include CustomerConcern
  customer_concern_callbacks

  belongs_to :invoice, inverse_of: :invoice_items
  belongs_to :customer

  monetize :amount_cents, with_model_currency: :currency
  delegate :organization, to: :invoice

  validates :invoice, presence: true
  validates :amount, presence: true
  validates :description, presence: true, if: 'customer_name.blank?'
  validates :amount, numericality: { greater_than: 0,
    less_than_or_equal_to: Dictionaries.money_max }
end
