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

class InvoiceItem < ActiveRecord::Base
  monetize :amount_cents, with_model_currency: :currency

  belongs_to :invoice, inverse_of: :invoice_items
  belongs_to :customer

  validates :invoice, :amount, presence: true
  validates :amount, numericality: { greater_than: 0,
    less_than_or_equal_to: Dictionaries.money_max }
  validate :customer_or_description

  private

  def customer_or_description
    if customer_id.nil? && description.blank?
      errors.add(:customer_id, 'Customer or Description must be present')
      errors.add(:description, 'Customer or Description must be present')
    end
  end
end
