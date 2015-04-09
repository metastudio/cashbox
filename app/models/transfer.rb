class Transfer
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  attr_accessor :amount_cents, :amount, :comission_cents, :comission, :comment,
    :bank_account, :bank_account_id, :reference_id,
    :inc_transaction, :out_transaction, :exchange_rate,
    :from_currency, :to_currency

  validates :amount, presence: true,
    numericality: { less_than_or_equal_to: Dictionaries.money_max }
  validates :comission, numericality: { greater_than_or_equal_to: 0 },
    length: { maximum: 10 }, allow_blank: true
  validates :comment, length: { maximum: 255 }
  validates_presence_of :bank_account_id
  validates :reference_id, presence: true
  validates :exchange_rate, presence: true, numericality: { greater_than: 0,
    less_than: 10_000 }, if: :currency_mismatch?
  validate :transfer_amount, unless: Proc.new { bank_account_id.blank? }
  validate :transfer_account

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    @from_currency = bank_account.try(:currency)
    @to_currency   = BankAccount.find_by(id: reference_id).try(:currency)
  end

  def save
    if valid?
      @out_transaction = Transaction.new(
        amount_cents: estimate_amount(out = true),
        bank_account_id: bank_account_id, comment: form_comment(comment),
        category_id: Category.find_or_create_by(
          Category::CATEGORY_BANK_EXPENSE_PARAMS).id)

      @inc_transaction = Transaction.new(
        amount_cents: estimate_amount(out = false),
        bank_account_id: reference_id, comment: form_comment(comment),
        category_id: Category.find_or_create_by(
          Category::CATEGORY_BANK_INCOME_PARAMS).id)

      if @out_transaction.invalid?
        parse_errors(@out_transaction)
        return false
      elsif @inc_transaction.invalid?
        parse_errors(@inc_transaction)
        return false
      else
        @out_transaction.save
        @inc_transaction.save
        return true
      end
    else
      false
    end
  end

  def save!
    (raise self.inspect) unless save
  end

  # needed for simple form for non db model
  def to_key
  end

  def persisted?
    false
  end

  def money_amount
    Money.new(amount_cents, bank_account.currency)
  end

  def money_comission
    Money.new(comission_cents, bank_account.currency)
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

  def exchange_rate=(value)
    @exchange_rate = (value ? value.to_d : nil)
  end

  def currency_mismatch?
    from_currency != to_currency
  end

  private
    def transfer_amount
      if bank_account.balance < money_amount + money_comission
        errors.add(:amount, 'Not enough money')
      end
    end

    def transfer_account
      if bank_account_id == reference_id
        errors.add(:reference_id, "Can't transfer to same account")
      end
    end

    def bank_account
     @bank_account ||= BankAccount.find_by(id: bank_account_id)
    end

    def form_comment(comment)
      comment.to_s + "\nComission: " + (comission.blank? ? "0" : comission.to_s)
    end

    def estimate_amount(out)
      estimated_amount = out ? (amount_cents + comission_cents) : amount_cents
      if currency_mismatch?
        Money.add_rate(from_currency, to_currency, exchange_rate.to_d)
        estimated_amount = if out
          Money.new(estimated_amount, from_currency).cents
        else
          Money.new(estimated_amount, from_currency).exchange_to(to_currency).cents
        end
      end
      estimated_amount
    end

    def parse_errors(transaction)
      transaction.errors.messages.each do |err_msg|
        field, msg = 0, 1
        errors.add(err_msg[field], err_msg[msg].join(', '))
      end
    end
end
