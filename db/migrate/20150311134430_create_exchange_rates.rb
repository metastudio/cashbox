class CreateExchangeRates < ActiveRecord::Migration
  def change
    create_table :exchange_rates do |t|
      t.hstore :rates, null: false
      t.datetime :updated_from_bank_at, null: false
      t.timestamps
    end
  end
end
