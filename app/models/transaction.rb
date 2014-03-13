class Transaction < ActiveRecord::Base
  CURRENCIES = %w(USD RUB)

  belongs_to :category
  belongs_to :bank_account

  monetize :amount_cents, with_model_currency: :amount_currency, allow_nil: true

  default_scope { order(created_at: :desc) }

  validates :amount,          presence: true
  validates :amount_currency, presence: true
  validates :amount_currency, inclusion: { in: CURRENCIES, message: "%{value} is not a valid currency" }
  validates :category_id, presence: true
  validates :bank_account_id,  presence: true

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
