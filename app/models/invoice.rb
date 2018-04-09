# frozen_string_literal: true

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
#  number          :string
#

class Invoice < ApplicationRecord
  include CustomerConcern
  include Period
  customer_concern_callbacks

  belongs_to :organization, inverse_of: :invoices
  belongs_to :customer, inverse_of: :invoices
  has_one :income_transaction, inverse_of: :invoice, foreign_key: 'invoice_id', class_name: 'Transaction', dependent: :nullify
  has_many :invoice_items, inverse_of: :invoice, dependent: :destroy

  accepts_nested_attributes_for :invoice_items,
    reject_if: :all_blank, allow_destroy: true

  monetize :amount_cents, with_model_currency: :currency

  validates :organization, presence: true
  validates :ends_at, presence: true
  validates :amount, presence: true
  validates :currency, presence: true
  validates :customer_name, presence: true, unless: :customer_id
  validates :number, length: { maximum: 16 }
  validates :amount, numericality: { greater_than: 0, less_than_or_equal_to: Dictionaries.money_max }
  validates :currency, inclusion: { in: Dictionaries.currencies, message: '%{value} is not a valid currency' }
  validates :ends_at, date: { after_or_equal_to: :starts_at }, if: :starts_at

  scope :ordered, -> { order('created_at DESC') }
  scope :unpaid, -> { where(paid_at: nil) }

  before_validation :calculate_total_amount, if: proc{ invoice_items.reject(&:marked_for_destruction?).any? }
  before_validation :strip_number
  after_save :set_currency
  after_create :send_notification

  class << self
    def ransackable_scopes(_auth_object = nil)
      %i[unpaid]
    end
  end

  def pdf_filename
    "#{customer}_#{ends_at.month}_#{ends_at.year}"
  end

  def invoice_details
    return nil unless organization
    return nil unless currency

    organization.bank_accounts.visible.by_currency(currency).first&.invoice_details
  end

  def customer_details
    customer&.invoice_details
  end

  def has_income_transaction?
    income_transaction.present?
  end

  private

  def send_notification
    NotificationJob.perform_later(organization.name,
      'Invoice was added',
      "Invoice was added to organization #{organization.name}")
  end

  def strip_number
    number.strip! if number.present?
  end

  def calculate_total_amount
    self.amount_cents = invoice_items.reject(&:marked_for_destruction?).sum(&:amount_cents)
  end

  def set_currency
    invoice_items.each{ |i| i.update(currency: currency) }
  end
end
