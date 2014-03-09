class Invoice < ActiveRecord::Base
  belongs_to :organization, inverse_of: :invoice

  monetize :balance_cents, allow_nil: false, numericality: {
    greater_than_or_equal_to: 0
  }

  validates :name,         presence: true
  validates :currency,     presence: true
end
