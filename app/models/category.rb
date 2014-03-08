class Category < ActiveRecord::Base
  belongs_to :organization, inverse_of: :category

  CATEGORY_TYPE = %w[Income Expense]

  validates :type, presence: true
  validates :type, inclusion: { in: %w(Income Expense),
                     message: "%{value} is not a valid category" }
  validates :name, presence: true

  scope :incomes,  -> { where(type: 'Income')  }
  scope :expenses, -> { where(type: 'Expense') }
end
