class Transaction < ActiveRecord::Base
  CURRENCIES = %w(USD RUB)

  belongs_to :category, inverse_of: :transactions
  belongs_to :bank_account, inverse_of: :transactions
  has_one :organization, through: :bank_account, inverse_of: :transactions

  monetize :amount_cents, with_model_currency: :currency

  delegate :currency, to: :bank_account, allow_nil: true

  default_scope { order(created_at: :desc) }

  validates :amount,   presence: true
  validates :category, presence: true
  validates :bank_account, presence: true

  after_save do |transaction|
    recalculate_amount(transaction)
  end

  private

  def recalculate_amount(p_transaction)
    unless p_transaction.bank_account.nil?
      p_transaction.bank_account.recalculate_amount
      p_transaction.bank_account.save!
    end
  end
end
