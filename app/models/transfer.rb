class Transfer
  include ActiveModel::Validations

  attr_accessor :amount_cents, :amount, :comission_cents, :comission, :comment,
    :bank_account, :bank_account_id, :reference_id,
    :inc_transaction, :out_transaction, :exchange_rate,
    :from_currency, :to_currency

  validates :amount, presence: :true, numericality: { greater_than: 0 },
    length: { maximum: 20 }
  validates :comission, numericality: { greater_than_or_equal_to: 0 },
    length: { maximum: 10 }, allow_blank: true
  validates :comment, length: { maximum: 255 }
  validates_presence_of :bank_account_id
  validates :reference_id, presence: true
  validates :exchange_rate, presence: true, numericality: { greater_than: 0 },
    if: Proc.new { @from_currency != @to_currency }
  validate :transfer_amount, unless: Proc.new { bank_account_id.blank? }
  validate :transfer_account

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def save
    if valid?
      set_currencies
      @out_transaction = Transaction.new(
        amount_cents: estimate_amount(out = true),
        bank_account_id: @bank_account_id, comment: form_comment(@comment),
        category_id: Category.find_or_create_by(
          Category::CATEGORY_BANK_EXPENSE_PARAMS).id)

      @inc_transaction = Transaction.new(
        amount_cents: estimate_amount(inc = false),
        bank_account_id: @reference_id, comment: form_comment(@comment),
        category_id: Category.find_or_create_by(
          Category::CATEGORY_BANK_INCOME_PARAMS).id)

      if !@out_transaction.save || !@inc_transaction.save
        errors[:base] << @out_transaction.errors
        errors[:base] << @inc_transaction.errors
        return false
      else
        return true
      end
    else
      false
    end
  end

  def save!
    save ? self : (raise self.inspect)
  end

  # needed for simple form for non db model
  def to_key
  end

  def persisted?
    false
  end

  def money_amount
    Money.new(@amount_cents, bank_account.currency)
  end

  def money_comission
    Money.new(@comission_cents, bank_account.currency)
  end

  def amount=(value)
    if value
      @amount_cents = value.to_d * 100
      @amount = value
    else
      @amount, @amount_cents = nil, nil
    end
  end

  def comission=(value)
    if value
      @comission_cents = value.to_d * 100
      @comission = value
    else
      @comission, @comission_cents = nil, nil
    end
  end

  private
    def transfer_amount
      if bank_account.balance < money_amount + money_comission
        errors.add(:amount, 'Not enough money')
      end
    end

    def transfer_account
      if @bank_account_id == @reference_id
        errors.add(:reference_id, "Can't transfer to same account")
      end
    end

    def bank_account
     @bank_account ||= BankAccount.find(@bank_account_id)
    end

    def form_comment(comment)
      comment.to_s + "\nComission: " + (comission.blank? ? "0" : comission.to_s)
    end

    def set_currencies
      @from_currency = bank_account.currency
      @to_currency   = BankAccount.find(reference_id).currency
    end

    def estimate_amount(out)
      estimated_amount = out ? (@amount_cents + @comission_cents) : @amount_cents
      if @from_currency != @to_currency
        Money.add_rate(@from_currency, @to_currency, @exchange_rate)
        estimated_amount = if out
          Money.new(estimated_amount, @from_currency).cents
        else
          Money.new(estimated_amount, @from_currency).exchange_to(@to_currency).cents
        end
      end
      estimated_amount
    end
end
