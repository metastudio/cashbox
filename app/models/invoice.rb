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
  has_many :invoice_items, inverse_of: :invoice, dependent: :destroy

  accepts_nested_attributes_for :invoice_items,
    reject_if: :all_blank, allow_destroy: true

  monetize :amount_cents, with_model_currency: :currency

  validates :organization, presence: true
  validates :ends_at, presence: true
  validates :amount, presence: true
  validates :currency, presence: true
  validates :customer_name, presence: true

  validates :amount, numericality: { greater_than: 0,
    less_than_or_equal_to: Dictionaries.money_max }
  validates :currency, inclusion: { in: Dictionaries.currencies,
    message: "%{value} is not a valid currency" }
  validate :check_overlap_dates_for_customer, if: 'customer_name.present?'

  scope :ordered,    -> { order('created_at DESC') }
  scope :all_except, -> (invoice) { where.not(id: invoice) }

  after_save :set_currency

  private

  def check_overlap_dates_for_customer
    self.customer.invoices.all_except(self.id).where(organization: self.organization).each do |i|
      self_start = self.starts_at ? self.starts_at : self.ends_at
      i_start = i.starts_at ? i.starts_at : i.ends_at
      if (self_start..self.ends_at).overlaps? (i_start..i.ends_at)
        errors.add(:starts_at, 'Overlap date for this customer') if self.starts_at
        errors.add(:ends_at, 'Overlap date for this customer')
      end
    end
  end

  def set_currency
    invoice_items.each{ |i| i.update(currency: currency) }
  end
end
