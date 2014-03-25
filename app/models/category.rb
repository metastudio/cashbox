# == Schema Information
#
# Table name: categories
#
#  id              :integer          not null, primary key
#  type            :string(255)      not null
#  name            :string(255)      not null
#  organization_id :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#

class Category < ActiveRecord::Base
  CATEGORY_INCOME = 'Income'
  CATEGORY_EXPENSE = 'Expense'
  CATEGORY_TYPES = [CATEGORY_INCOME, CATEGORY_EXPENSE]

  self.inheritance_column = nil

  belongs_to :organization, inverse_of: :categories
  has_many :transactions, inverse_of: :category, dependent: :restrict_with_exception

  validates :type, presence: true, inclusion: { in: CATEGORY_TYPES, message: "%{value} is not a valid category type" }
  validates :name, presence: true

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
