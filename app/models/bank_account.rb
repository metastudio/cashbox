require 'uri'

class BankAccount < ActiveRecord::Base
  CURRENCIES = %w(USD RUB)

  belongs_to :organization, inverse_of: :bank_account
  
  composed_of :balance,
              class_name: "Money",
              mapping: [%w(balance_cents cents), %w(balance_currency currency_as_string)],
              constructor: Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) },
              converter: Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }
  
  validates :name,             presence: true
  validates :balance,          presence: true
  validates :balance_currency, presence: true
  validates :balance_currency, inclusion: { in: CURRENCIES,
                               message: "%{value} is not a valid currency" }

  def self.total_balance
    sum(&:balance)
  end
end
