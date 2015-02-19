class AddCurrencyToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :currency, :string, default: "USD"
  end
end
