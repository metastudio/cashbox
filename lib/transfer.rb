class Transfer
  include ActiveModel::Validations

  attr_accessor :amount, :category_id, :comment,
    :bank_account_id, :reference_id, :comission

  # validates :amount, presence: :true, numericality: { greater_than: 0 }
  validates_presence_of :bank_account_id
  validates :reference_id, presence: true
  validates :comission, numericality: { greater_than: 0 }
  validate :transfer_amount
  validate :transfer_currency
  validate :transfer_account

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def save(transaction)
    if valid?
      out_transaction = Transaction.create(
        amount: amount.to_f + comission.to_f, bank_account_id: bank_account_id,
        reference_id: reference_id, comment: comment,
        category_id: Category.find_or_create_by(
          Category::CATEGORY_BANK_EXPENSE_PARAMS).id,
        transaction_type: 'Transfer')

      inc_transaction = Transaction.create(
        amount: amount, bank_account_id: reference_id,
        reference_id: bank_account_id, comment: comment,
        category_id: Category.find_or_create_by(
          Category::CATEGORY_BANK_INCOME_PARAMS).id,
        transaction_type: 'Receipt')

      if (out_transaction.errors.any? && inc_transaction.errors.any?)
        transaction.errors[:base] << out_transaction.errors.full_messages
        transaction.errors[:base] << inc_transaction.errors.full_messages
      end
    else
      errors.each do |key, value|
        transaction.errors.add(key, value)
      end
    end

    [inc_transaction, out_transaction]
  end

  private

    def transfer_amount
      if !bank_account_id.empty? &&
          BankAccount.find(bank_account_id).balance.to_f < amount.to_f + comission.to_f
        errors.add(:amount, 'Not enough money')
      end

    end

    def transfer_currency
      if !bank_account_id.empty? && !reference_id.empty? &&
          BankAccount.find(bank_account_id).currency != BankAccount.find(reference_id).currency
        errors.add(:reference_id, "Can't transfer to account with different currency")
      end
    end

    def transfer_account
      if bank_account_id == reference_id
        errors.add(:reference_id, "Can't transfer to same account")
      end
    end
end
