# frozen_string_literal: true

class Transfer
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include MoneyRails::ActionViewExtension
  include MainPageRefresher

  attr_reader :amount, :comission, :exchange_rate
  attr_writer :bank_account
  attr_accessor :amount_cents, :comission_cents, :comment,
    :bank_account_id, :reference_id, :date,
    :inc_transaction, :out_transaction,
    :from_currency, :to_currency, :calculate_sum, :created_by, :leave_open

  validates :amount,
    presence:     true,
    numericality: { less_than_or_equal_to: Dictionaries.money_max, other_than: 0 }
  validates :comission,
    numericality: { greater_than_or_equal_to: 0 },
    length:       { maximum: 10 }, allow_blank: true
  validates :calculate_sum,
    numericality: { greater_than_or_equal_to: 0 },
    length:       { maximum: 25 },
    allow_blank:  true
  validates :comment, length: { maximum: 255 }
  validates :bank_account_id, presence: true
  validates :reference_id, presence: true
  validates :exchange_rate,
    presence:     true,
    numericality: { greater_than: 0, less_than: 10_000 },
    if:           :currency_mismatch?
  validate :transfer_account
  validate :check_comission, if: :comission

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
        amount_cents:    estimate_amount(true),
        bank_account_id: bank_account_id, comment: form_comment(comment),
        date:            date,
        category_id:     Category.find_or_create_by(Category::CATEGORY_BANK_EXPENSE_PARAMS).id,
        created_by:      created_by,
      )

      @inc_transaction = Transaction.new(
        amount_cents: estimate_amount(false),
        bank_account_id: reference_id, comment: form_comment(comment),
        date: date,
        category_id: Category.find_or_create_by(Category::CATEGORY_BANK_INCOME_PARAMS).id,
        created_by: created_by
      )

      if @out_transaction.invalid?
        parse_errors(@out_transaction)
        return false
      elsif @inc_transaction.invalid?
        parse_errors(@inc_transaction)
        return false
      else
        @out_transaction.save
        @inc_transaction.transfer_out_id = @out_transaction.id
        @inc_transaction.save
        NotificationJob.perform_later(
          bank_account.organization.name,
          'Transfer was created',
          "Transfer was created in #{bank_account.name} bank account"
        )
        MainPageRefreshJob.perform_later(
          bank_account.organization.name,
          prepare_data(@inc_transaction)
        )
        return true
      end
    else
      false
    end
  end

  def save!
    (raise inspect) unless save
  end

  # needed for simple form for non db model
  def to_key; end

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
      @amount       = value
    else
      @amount_cents = nil
      @amount       = nil
    end
  end

  def comission=(value)
    if value
      @comission_cents = value.to_d * 100
      @comission       = value
    else
      @comission_cents = nil
      @comission       = nil
    end
  end

  def exchange_rate=(value)
    @exchange_rate = (value ? value.to_d : nil)
  end

  def currency_mismatch?
    from_currency != to_currency
  end

  private

  def check_comission
    errors.add(:comission, "Can't be more than amount") if comission.to_d > amount.to_d
  rescue StandardError
    nil
  end

  def transfer_account
    return if bank_account_id != reference_id

    errors.add(:reference_id, "Can't transfer to same account")
  end

  def bank_account
    @bank_account ||= BankAccount.find_by(id: bank_account_id)
  end

  def form_comment(comment)
    rate = currency_mismatch? ? "\nRate: " + exchange_rate.to_s : ''

    comission_str = ''
    if comission != '0.00'
      comission_str = "\nComission: " + humanized_money_with_symbol(money_comission, symbol_after_without_space: true)
    end

    comment.to_s + comission_str + rate
  end

  def estimate_amount(out)
    estimated_amount = out && comission_cents ? (amount_cents + comission_cents) : amount_cents
    if currency_mismatch?
      rate = Money.default_bank.get_rate(from_currency, to_currency)
      Money.default_bank.add_rate(from_currency, to_currency, exchange_rate.to_d)
      estimated_amount =
        if out
          Money.new(estimated_amount, from_currency).cents
        else
          Money.new(estimated_amount, from_currency).exchange_to(to_currency).cents
        end
      Money.default_bank.add_rate(from_currency, to_currency, rate)
    end
    estimated_amount
  end

  def parse_errors(transaction)
    transaction.errors.messages.each do |err_msg|
      field = 0
      msg   = 1
      errors.add(err_msg[field], err_msg[msg].join(', '))
    end
  end
end
