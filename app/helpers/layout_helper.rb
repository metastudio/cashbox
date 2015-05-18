module LayoutHelper
  def active_org(org)
    (org.id == current_organization.id ? 'active' : '')
  end

  def colorize_transaction(transaction)
    css_class = colorize_amount(transaction.amount)

    if params[:controller] != 'transactions' && current_member.last_visited_at
      if transaction.created_at > current_member.last_visited_at
        css_class += ' new_transaction'
      end
    end

    css_class
  end
end
