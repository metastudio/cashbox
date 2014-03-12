class BankAccount < ActiveRecord::Base
  CURRENCIES = %w(USD RUB)

  has_many :transactions
  belongs_to :organization, inverse_of: :bank_account

  monetize :balance_cents, with_model_currency: :balance_currency, allow_nil: true
  
  validates :name,             presence: true
  validates :balance,          presence: true
  validates :balance_currency, presence: true
  validates :balance_currency, inclusion: { in: CURRENCIES, message: "%{value} is not a valid currency" }

  def self.total_balance_in_dollars
    BankAccount.where(balance_currency: 'USD').sum(&:balance)
  end

  def self.total_balance_in_rubles
    BankAccount.where(balance_currency: 'RUB').sum(&:balance)
  end

  def recalculate_amount
    due = self.balance
    self.transactions.each do |transaction|
      due -= transaction.amount
    end

    self.balance = due
  end
end
