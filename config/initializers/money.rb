# encoding : utf-8
require './lib/russian_central_bank_safe.rb'

MoneyRails.configure do |config|
  # To set the default currency
  #
  # config.default_currency = :usd

  # Set default bank object
  #
  # Example:
  # config.default_bank = EuCentralBank.new
  config.default_bank = RussianCentralBankSafe.new
  config.default_bank.ttl = 1.day # autoupdate every day

  # Add exchange rates to current money bank object.
  # (The conversion rate refers to one direction only)
  #
  # Example:
  # config.add_rate "USD", "CAD", 1.24515
  # config.add_rate "CAD", "USD", 0.803115
  config.add_rate "RUB", "USD", 0.013513
  config.add_rate "USD", "RUB", 74

  config.add_rate "EUR", "USD", 1.12
  config.add_rate "USD", "EUR", 0.892

  # To handle the inclusion of validations for monetized fields
  # The default value is true
  #
  # config.include_validations = true

  # Default ActiveRecord migration configuration values for columns:
  #
  # config.amount_column = { prefix: '',           # column name prefix
  #                          postfix: '_cents',    # column name  postfix
  #                          column_name: nil,     # full column name (overrides prefix, postfix and accessor name)
  #                          type: :integer,       # column type
  #                          present: true,        # column will be created
  #                          null: false,          # other options will be treated as column options
  #                          default: 0
  #                        }
  #
  # config.currency_column = { prefix: '',
  #                            postfix: '_currency',
  #                            column_name: nil,
  #                            type: :string,
  #                            present: true,
  #                            null: false,
  #                            default: 'USD'
  #                          }

  # Register a custom currency
  #
  # Example:
  config.register_currency = {
    :priority            => 2,
    :iso_code            => "RUB",
    :name                => "Russian Ruble",
    :symbol              => "₽",
    :symbol_first        => false,
    :subunit             => "Kopek",
    :subunit_to_unit     => 100,
    :thousands_separator => ".",
    :decimal_mark        => ","
  }

  # Set money formatted output globally.
  # Default value is nil meaning "ignore this option".
  # Options are nil, true, false.
  #
  # config.no_cents_if_whole = nil
  # config.symbol = nil
  config.sign_before_symbol = true
  if ActiveRecord::Base.connection.table_exists? 'exchange_rates'
    ExchangeRate.update_rates
  end
end
