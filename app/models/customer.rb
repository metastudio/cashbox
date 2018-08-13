# frozen_string_literal: true

# == Schema Information
#
# Table name: customers
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  organization_id :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#  deleted_at      :datetime
#  invoice_details :text
#

class Customer < ApplicationRecord
  acts_as_paranoid

  belongs_to :organization, inverse_of: :customers
  has_many :transactions, inverse_of: :customer, dependent: :nullify
  has_many :invoices, inverse_of: :customer, dependent: :restrict_with_error
  has_many :invoice_items, dependent: :restrict_with_error

  validates :name, presence: true
  validates :organization, presence: true
  validates :name, uniqueness: { scope: %i[organization_id deleted_at] }

  scope :ordered, -> { order(:name) }
  scope :with_name, ->(name) { where('name ilike ?', "%#{name}%") }

  # gem 'paranoia' doesn't run validation callbacks on restore
  before_restore :run_validations

  def to_s
    name.truncate(30)
  end

  private

  def run_validations
    self.deleted_at = nil
    validate!
  end
end
