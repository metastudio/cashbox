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
#  amount_currency :string           default("USD"), not null
#  sent_at         :datetime
#  paid_at         :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

class Invoice < ActiveRecord::Base
  attr_accessor :customer_name

  belongs_to :organization, inverse_of: :invoices
  belongs_to :customer, inverse_of: :invoices
  has_many :invoice_items, inverse_of: :invoice, dependent: :destroy

  accepts_nested_attributes_for :invoice_items,
    reject_if: :all_blank, allow_destroy: true

  monetize :amount_cents, with_model_currency: :currency

  validates :organization, presence: true
  validates :ends_at, presence: true
  validates :amount, presence: true
  validates :currency, presence: true
  validates :customer_name, length: { maximum: 255 }
  validates :amount, numericality: { greater_than: 0,
    less_than_or_equal_to: Dictionaries.money_max }
  validates :currency, inclusion: { in: Dictionaries.currencies,
    message: "%{value} is not a valid currency" }

  scope :ordered, -> { order('created_at DESC') }

  before_validation :find_customer, if: Proc.new{ customer_name.present? }

  private

  def find_customer
    self.customer = Customer.find_or_initialize_by(name: customer_name, organization_id: organization.id)
  end
end
