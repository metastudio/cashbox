module LayoutHelper
  def active_org(org)
    (org.id == current_organization.id ? 'active' : '')
  end

  def total_amount(currency)
    money_with_symbol current_organization.bank_accounts.
      total_balance(currency)
  end
end
