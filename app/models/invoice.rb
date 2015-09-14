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

class Invoice < ActiveRecord::Base
  include CustomerConcern
  customer_concern_callbacks

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

  validates :amount, numericality: { greater_than: 0,
    less_than_or_equal_to: Dictionaries.money_max }
  validates :currency, inclusion: { in: Dictionaries.currencies,
    message: "%{value} is not a valid currency" }

  scope :ordered, -> { order('created_at DESC') }

  after_save :set_currency

  private

  def self.period(period)
    case period
    when 'current-month'
      where('invoices.ends_at >= ? AND invoices.ends_at <= ?', Time.now.beginning_of_month, Time.now)
    when 'last-3-months'
      where('invoices.ends_at >= ? AND invoices.ends_at <= ?', (Time.now - 3.months).beginning_of_day, Time.now)
    when 'prev-month'
      prev_month_begins = Time.now.beginning_of_month - 1.months
      where('invoices.ends_at between ? AND ?', prev_month_begins,
        prev_month_begins.end_of_month)
    when 'this-year'
      where('invoices.ends_at >= ? AND invoices.ends_at <= ?', Time.now.beginning_of_year, Time.now)
    when 'quarter'
      where('invoices.ends_at >= ? AND invoices.ends_at <= ?', Time.now.beginning_of_quarter, Time.now)
    else
      all
    end
  end

  def set_currency
    invoice_items.each{ |i| i.update(currency: currency) }
  end
end
