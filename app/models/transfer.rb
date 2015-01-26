class Transfer
  include ActiveModel::Validations

  attr_accessor :amount_cents, :comment,
    :bank_account_id, :reference_id, :comission_cents,
    :inc_transaction, :out_transaction,
    :bank_account

  monetize :amount_cents, with_model_currency: :currency
  monetize :comission_cents, with_model_currency: :currency

  delegate :currency, to: :bank_account, allow_nil: true

  validates :amount, presence: :true, numericality: { greater_than: 0 }
  validates_presence_of :bank_account_id
  validates :reference_id, presence: true
  validates :comission, numericality: { greater_than: 0 }
  validate :transfer_amount
  validate :transfer_currency
  validate :transfer_account

  def initialize(attributes = { amount: nil, comment: nil, bank_account_id: nil,
    reference_id: nil, comission: nil, inc_transaction: nil, out_transaction: nil,
    bank_account: nil } )
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def save(transaction)
    if valid?
      @out_transaction = Transaction.create(
        amount_cents: (amount.to_f + comission.to_f) * 100, bank_account_id: bank_account_id,
        reference_id: reference_id, comission: comission,
        comment: form_comment(comment),
        category_id: Category.find_or_create_by(
          Category::CATEGORY_BANK_EXPENSE_PARAMS).id,
        transaction_type: 'Transfer')

      @inc_transaction = Transaction.create(
        amount_cents: amount.to_f * 100, bank_account_id: reference_id,
        reference_id: bank_account_id, comission: comission,
        comment: form_comment(comment),
        category_id: Category.find_or_create_by(
          Category::CATEGORY_BANK_INCOME_PARAMS).id,
        transaction_type: 'Receipt')

      if (@out_transaction.errors.any? || @inc_transaction.errors.any?)
        errors[:base] << out_transaction.errors.full_messages
        errors[:base] << inc_transaction.errors.full_messages
      end
    end
  end

  private

    def transfer_amount
      if !bank_account_id.blank? &&
          bank_account.balance.to_f < amount.to_f + comission.to_f
        errors.add(:amount, 'Not enough money')
      end
    end

    def transfer_currency
      if !bank_account_id.blank? && !reference_id.blank? &&
          bank_account.currency != BankAccount.find(reference_id).currency
        errors.add(:reference_id, "Can't transfer to account with different currency")
      end
    end

    def transfer_account
      if bank_account_id == reference_id
        errors.add(:reference_id, "Can't transfer to same account")
      end
    end

    def form_comment(comment)
      comment.to_s + "\nComission: " + comission.to_s
    end

    def bank_account
      @bank_account ||= BankAccount.find(bank_account_id)
    end
end
