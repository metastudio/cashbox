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
  self.inheritance_column = nil

  belongs_to :organization, inverse_of: :categories
  has_many :transactions, inverse_of: :category, dependent: :restrict_with_exception

  CATEGORY_TYPES = %w[Income Expense]

  validates :type, presence: true
  validates :type, inclusion: { in: CATEGORY_TYPES, message: "%{value} is not a valid category" }
  validates :name, presence: true

  scope :incomes,  -> { where(type: 'Income')  }
  scope :expenses, -> { where(type: 'Expense') }
end
