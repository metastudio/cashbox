# == Schema Information
#
# Table name: invoices
#
#  id              :integer          not null, primary key
#  organization_id :integer          not null
#  customer_id     :integer          not null
#  starts_at       :date
#  ends_at         :date             not null
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
  has_one :income_transaction, foreign_key: 'invoice_id', class_name: 'Transaction'
  has_many :invoice_items, inverse_of: :invoice, dependent: :destroy

  accepts_nested_attributes_for :invoice_items,
    reject_if: :all_blank, allow_destroy: true

  monetize :amount_cents, with_model_currency: :currency

  validates :organization, presence: true
  validates :ends_at, presence: true
  validates :amount, presence: true
  validates :currency, presence: true
  validates :customer_name, presence: true, unless: :customer_id

  validates :amount, numericality: { greater_than: 0,
    less_than_or_equal_to: Dictionaries.money_max }
  validates :currency, inclusion: { in: Dictionaries.currencies,
    message: "%{value} is not a valid currency" }
  validates :starts_at, :ends_at, overlap: { scope: 'customer_id', message_content: 'overlaps with another Invoice' }
  validates :ends_at, date: { after_or_equal_to: :starts_at }, if: :starts_at

  scope :ordered, -> { order('created_at DESC') }

  before_validation :calculate_total_amount, if: Proc.new{ invoice_items.reject(&:marked_for_destruction?).any? }
  after_save :set_currency

  def pdf_filename
    "#{self.customer.to_s}_#{self.ends_at.month}_#{self.ends_at.year}"
  end

  private

  def self.period(period)
    case period
    when 'current-month'
      where('DATE(invoices.ends_at) between ? AND ?', Date.current.beginning_of_month, Date.current.end_of_month)
    when 'last-3-months'
      where('DATE(invoices.ends_at) between ? AND ?', (Date.current - 3.months).beginning_of_day, Date.current.end_of_month)
    when 'prev-month'
      prev_month_begins = Date.current.beginning_of_month - 1.months
      where('DATE(invoices.ends_at) between ? AND ?', prev_month_begins,
        prev_month_begins.end_of_month)
    when 'this-year'
      where('DATE(invoices.ends_at) between ? AND ?', Date.current.beginning_of_year, Date.current.end_of_year)
    when 'quarter'
      where('DATE(invoices.ends_at) between ? AND ?', Date.current.beginning_of_quarter, Date.current.end_of_quarter)
    else
      all
    end
  end

  def calculate_total_amount
    self.amount_cents = invoice_items.reject(&:marked_for_destruction?).sum(&:amount_cents)
  end

  def set_currency
    invoice_items.each{ |i| i.update(currency: currency) }
  end
end
