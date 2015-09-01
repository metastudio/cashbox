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
  monetize :amount_cents, with_model_currency: :currency

  scope :ordered, -> { order('created_at DESC') }

  belongs_to :organization, inverse_of: :invoices
  belongs_to :customer, inverse_of: :invoices
  has_many :invoice_items, inverse_of: :invoice, dependent: :destroy
  accepts_nested_attributes_for :invoice_items,
    reject_if: proc { |param| param[:amount].blank? },
    allow_destroy: true

  validates :organization, :customer_id, :ends_at, :amount, :currency, presence: true
  validates :amount, numericality: { greater_than: 0,
    less_than_or_equal_to: Dictionaries.money_max }
  validates :currency, inclusion: { in: Dictionaries.currencies,
    message: "%{value} is not a valid currency" }
end
