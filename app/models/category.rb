# == Schema Information
#
# Table name: categories
#
#  id              :integer          not null, primary key
#  type            :string           not null
#  name            :string           not null
#  organization_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#  system          :boolean          default("false")
#

class Category < ActiveRecord::Base
  CATEGORY_INCOME = 'Income'
  CATEGORY_EXPENSE = 'Expense'
  CATEGORY_TRANSFER_INCOME  = 'Receipt'
  CATEGORY_TRANSFER_OUTCOME = 'Transfer'
  CATEGORY_TYPES = [CATEGORY_INCOME, CATEGORY_EXPENSE]
  CATEGORY_BANK_INCOME_PARAMS = {
    type: Category::CATEGORY_INCOME,
    name: Category::CATEGORY_TRANSFER_INCOME,
    system: true
  }
  CATEGORY_BANK_EXPENSE_PARAMS = {
    type: Category::CATEGORY_EXPENSE,
    name: Category::CATEGORY_TRANSFER_OUTCOME,
    system: true
  }

  self.inheritance_column = nil

  belongs_to :organization, inverse_of: :categories
  has_many :transactions, inverse_of: :category, dependent: :restrict_with_exception

  validates :type, presence: true, inclusion: { in: CATEGORY_TYPES, message: "%{value} is not a valid category type" }
  validates :name, presence: true
  validates :organization_id, presence: true, unless: :system?

  scope :incomes,  -> { where(type: CATEGORY_INCOME)  }
  scope :expenses, -> { where(type: CATEGORY_EXPENSE) }

  class << self
    def grouped_by_type
      [
        [CATEGORY_INCOME, incomes],
        [CATEGORY_EXPENSE, expenses]
      ]
    end
  end

  def income?
    type == CATEGORY_INCOME
  end

  def expense?
    type == CATEGORY_EXPENSE
  end

end
