class Category < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :organization, inverse_of: :category

  CATEGORY_TYPE = %w[Income Expense]

  validates :type, presence: true
  validates :type, inclusion: { in: CATEGORY_TYPE,
                     message: "%{value} is not a valid category" }
  validates :name, presence: true

  scope :incomes,  -> { where(type: 'Income')  }
  scope :expenses, -> { where(type: 'Expense') }
end

