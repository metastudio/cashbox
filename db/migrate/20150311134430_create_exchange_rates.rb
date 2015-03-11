class CreateExchangeRates < ActiveRecord::Migration
  def change
    create_table :exchange_rates do |t|
      t.hstore :rates
      t.timestamps
    end
  end
end
