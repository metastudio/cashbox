# frozen_string_literal: true

# == Schema Information
#
# Table name: categories
#
#  id              :integer          not null, primary key
#  type            :string(255)      not null
#  name            :string(255)      not null
#  organization_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#  system          :boolean          default(FALSE)
#  deleted_at      :datetime
#

class Category < ApplicationRecord
  CATEGORY_INCOME  = 'Income'
  CATEGORY_EXPENSE = 'Expense'
  CATEGORY_TRANSFERS = 'Transfers'
  CATEGORY_TRANSFER_INCOME  = 'Transfer'
  CATEGORY_TRANSFER_OUTCOME = 'Transfer out'
  CATEGORY_TYPES = [CATEGORY_INCOME, CATEGORY_EXPENSE].freeze
  CATEGORY_BANK_INCOME_PARAMS = {
    type:   Category::CATEGORY_INCOME,
    name:   Category::CATEGORY_TRANSFER_INCOME,
    system: true,
  }.freeze
  CATEGORY_BANK_EXPENSE_PARAMS = {
    type:   Category::CATEGORY_EXPENSE,
    name:   Category::CATEGORY_TRANSFER_OUTCOME,
    system: true,
  }.freeze

  acts_as_paranoid

  self.inheritance_column = nil

  scope :ordered, -> { order(:type, :name) }

  belongs_to :organization, inverse_of: :categories, optional: true
  has_many :transactions, inverse_of: :category, dependent: :destroy

  validates :type, presence: true, inclusion: { in: CATEGORY_TYPES, message: '%{value} is not a valid category type' }
  validates :name, presence: true
  validates :organization_id, presence: true, unless: :system?

  scope :incomes,   ->{ where(type: CATEGORY_INCOME)  }
  scope :expenses,  ->{ where(type: CATEGORY_EXPENSE) }
  scope :receipts,  ->{ where(name: CATEGORY_TRANSFER_INCOME) }
  scope :transfers, ->{ where(name: CATEGORY_TRANSFER_OUTCOME) }
  scope :for_organization, ->(organization){ where('categories.system = ? OR categories.organization_id = ?', true, organization.id) }

  class << self
    def grouped_by_type
      [
        [CATEGORY_INCOME,    incomes - receipts],
        [CATEGORY_EXPENSE,   expenses - transfers],
        [CATEGORY_TRANSFERS, receipts],
      ]
    end

    def create_defaults(organization)
      [*DEFAULT_VALUES[:categories]].each do |category|
        organization.categories.find_or_create_by(
          name: category['name'].capitalize,
          type: category['type'].capitalize
        )
      end
    end

    def receipt_id
      find_by(name: CATEGORY_TRANSFER_INCOME).try(:id)
    end

    def transfer_out_id
      find_by(name: CATEGORY_TRANSFER_OUTCOME).try(:id)
    end
  end

  def to_s
    name.truncate(30)
  end

  def income?
    type == CATEGORY_INCOME
  end

  def expense?
    type == CATEGORY_EXPENSE
  end
end
