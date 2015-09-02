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
  attr_accessor :customer_name

  belongs_to :invoice, inverse_of: :invoice_items
  belongs_to :customer

  monetize :amount_cents, with_model_currency: :currency

  validates :invoice, presence: true
  validates :amount, presence: true
  validates :description, presence: true, unless: :customer_id?
  validates :amount, numericality: { greater_than: 0,
    less_than_or_equal_to: Dictionaries.money_max }

  before_validation :find_customer, if: Proc.new{ self.customer_name.present? }

  def customer_name=(value)
    attribute_will_change!("customer_name") if @customer_name != value
    @customer_name = value
  end

  private

  def find_customer
    self.customer = Customer.find_or_initialize_by(name: customer_name, organization_id: invoice.organization.id)
  end
end
