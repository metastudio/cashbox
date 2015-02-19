class AddCurrencyToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :default_currency, :string, default: "USD"
  end
end
