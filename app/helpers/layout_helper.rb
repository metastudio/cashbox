module LayoutHelper
  def active_org(org)
    (org.id == current_organization.id ? 'active' : '')
  end

  def active_sett(sett)
    params[:controller] == sett ? 'list-group-item active' : 'list-group-item'
  end

  def total_amount(currency)
    humanized_money_with_symbol current_organization.bank_accounts.
      total_balance(currency)
  end
end
