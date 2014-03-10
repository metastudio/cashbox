class Transaction < ActiveRecord::Base
  belongs_to :category
  belongs_to :invoice

  monetize :amount_cents, with_model_currency: :amount_currency, allow_nil: false, numericality: {
    greater_than_or_equal_to: 0
  }

  default_scope { order(created_at: :desc) }

  validates :amount, presence: true

  after_save do |transaction|
    recalculate_amount(transaction)
  end

  private

  def recalculate_amount(p_transaction)
    unless p_transaction.invoice.nil?
      p_transaction.invoice.recalculate_amount
      p_transaction.invoice.save!
    end
  end
end
