class Transfer
  include ActiveModel::Validations

  attr_accessor :amount_cents, :amount, :comission_cents, :comission, :comment,
    :bank_account, :bank_account_id, :reference_id,
    :inc_transaction, :out_transaction

  validates :amount, presence: :true, numericality: { greater_than: 0 }
  validates :comission, numericality: { greater_than: 0 }
  validates_presence_of :bank_account_id
  validates :reference_id, presence: true
  validate :transfer_amount
  validate :transfer_currency
  validate :transfer_account

  # def initialize(attributes = { amount_cents: nil, comment: nil, bank_account_id: nil,
  #   reference_id: nil, comission_cents: nil, inc_transaction: nil, out_transaction: nil,
  #   bank_account: nil, amount: nil, comission: nil } )

  def initialize(attributes = { amount_cents: nil, comment: nil, bank_account_id: nil,
    reference_id: nil, comission_cents: nil, inc_transaction: nil, out_transaction: nil,
    bank_account: nil, amount: nil, comission: nil } )
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def save
    # raise [self, self.valid?, self.errors].inspect
    if valid?
      @out_transaction = Transaction.create(
        amount_cents: amount_cents + comission_cents, bank_account_id: bank_account_id,
        reference_id: reference_id, comment: form_comment(comment),
        category_id: Category.find_or_create_by(
          Category::CATEGORY_BANK_EXPENSE_PARAMS).id)

      @inc_transaction = Transaction.create(
        amount_cents: amount_cents, bank_account_id: reference_id,
        reference_id: bank_account_id, comment: form_comment(comment),
        category_id: Category.find_or_create_by(
          Category::CATEGORY_BANK_INCOME_PARAMS).id)

      if (@out_transaction.errors.any? || @inc_transaction.errors.any?)
        errors[:base] << @out_transaction.errors
        errors[:base] << @inc_transaction.errors

        return false
      end

      true
    else
      false
    end
  end

  # is needed for simple form for non db model
  def to_key
  end

  def persisted?
    false
  end

  def money_amount
    Money.new(@amount_cents)
  end

  def money_comission
    Money.new(@comission_cents)
  end

  private
    def transfer_amount
      if !bank_account_id.blank? &&
          bank_account.balance < amount + comission
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
      @bank_account ||= BankAccount.find(bank_account_id) if bank_account_id
    end

end
