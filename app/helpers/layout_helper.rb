module LayoutHelper
  def active_org(org)
    (org.id == current_organization.id ? 'active' : '')
  end

  def colorize_transaction(transaction)
    css_class = colorize_amount(transaction.amount)
    if params[:controller] == 'home' && current_member
      if current_member.last_visited_at
        css_class += ' new-transaction' if transaction.created_at > current_member.last_visited_at
      end
    end
    css_class
  end

  def show_amount_with_tooltip(amount)
    cb = Money.default_bank
    def_curr = current_organization.default_currency
    link_to '#', class: 'exchange-helper', title: "#{amount.currency}/#{def_curr}, rate: #{cb.get_rate(amount.currency, def_curr).round(4)}, by #{l cb.rates_updated_at}", data: { toggle: 'tooltip', placement: 'top'} do
      raw("<span class='glyphicon glyphicon-question-sign'></span>")
    end
  end

  def submit_title
    params['action'] == 'new' ? 'Create' : 'Update'
  end
end
