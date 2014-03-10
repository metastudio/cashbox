class Invoice < ActiveRecord::Base
  has_many :transactions
  belongs_to :organization, inverse_of: :invoice

  scope :balance, -> { where("balance_cents > 0") }
  
  monetize :balance_cents, with_model_currency: :balance_currency, allow_nil: false, numericality: {
    greater_than_or_equal_to: 0
  }

  validates :name,             presence: true
  validates :balance_cents,    presence: true
  validates :balance_currency, presence: true

  def self.total_balance
    sum(&:balance)
  end

  def recalculate_amount
    due = self.balance
    self.transactions.each do |transaction|
      due -= transaction.amount
    end

    self.balance = due
  end
end
