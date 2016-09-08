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
  validates :hours, numericality: { greater_than: 0 }

  private

  def self.period(period)
    case period
    when 'current-month'
      where('DATE(invoice_items.date) between ? AND ?', Date.current.beginning_of_month, Date.current.end_of_month)
    when 'last-3-months'
      where('DATE(invoice_items.date) between ? AND ?', (Date.current - 3.months).beginning_of_day, Date.current.end_of_month)
    when 'prev-month'
      prev_month_begins = Date.current.beginning_of_month - 1.months
      where('DATE(invoice_items.date) between ? AND ?', prev_month_begins,
        prev_month_begins.end_of_month)
    when 'this-year'
      where('DATE(invoice_items.date) between ? AND ?', Date.current.beginning_of_year, Date.current.end_of_year)
    when 'quarter'
      where('DATE(invoice_items.date) between ? AND ?', Date.current.beginning_of_quarter, Date.current.end_of_quarter)
    else
      all
    end
  end
end
