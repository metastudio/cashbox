module LayoutHelper
  def active_org(org)
    (org.id == current_organization.id ? 'active' : '')
  end

  def colorize_transaction(transaction)
    if params[:controller] != 'transactions' && current_member.last_visited_at
      transaction.created_at > current_member.last_visited_at ? 'new_transaction' : ''
    end
  end
end
