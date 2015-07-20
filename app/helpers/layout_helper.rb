module LayoutHelper
  def active_org(org)
    (org.id == current_organization.id ? 'active' : '')
  end

  def colorize_transaction(transaction)
    css_class = colorize_amount(transaction.amount)
    if params[:controller] == 'home' && current_member.last_visited_at
      css_class += ' new-transaction' if transaction.created_at > current_member.last_visited_at
    end
    css_class
  end
end
