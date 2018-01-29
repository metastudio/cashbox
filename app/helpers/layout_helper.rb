module LayoutHelper
  def active_org(org)
    (org.id == current_organization.id ? 'active' : '')
  end

  def colorize_transaction(transaction)
    css_class = transaction.transfer? || transaction.transfer_out? ? 'transfer' : colorize_amount(transaction.amount)
    if params[:controller] == 'home' && current_member && current_member.last_visited_at
      css_class += ' new-transaction' if transaction.created_at > current_member.last_visited_at
    end
    css_class
  end

  def show_amount_with_tooltip(amount, default_currency)
    cb = Money.default_bank
    def_curr = default_currency
    show_tooltip_with_text("#{amount.currency}/#{def_curr}, rate: #{cb.get_rate(amount.currency, def_curr).round(4)}, by #{l cb.rates_updated_at}")
  end

  def show_tooltip_with_text(text)
    content_tag(:span, '', title: text, class: 'glyphicon glyphicon-question-sign exchange-helper',
      data: { toggle: 'tooltip', placement: 'top' } )
  end

  def submit_title
    if  params['action'] == 'new'
      'Create'
    else
      'Update'
    end
  end

  def invoices_debt(debtor)
    if debtor.is_a? Customer
      str = h "#{debtor.name}:"
    else
      str = "All customers:"
    end
    cb = Money.default_bank
    def_curr = current_organization.default_currency
    debtor.invoices.unpaid.group(:currency).sum(:amount_cents).each do |currency, amount_cents|
      m = Money.new(amount_cents, currency)

      if def_curr == currency
        str += " #{m.format};"
      else
        str += " #{m.format} (#{m.exchange_to(def_curr).format} "
        str += show_tooltip_with_text("#{currency}/#{def_curr}, \
          rate: #{cb.get_rate(currency, def_curr).round(4)}, by #{l cb.rates_updated_at}")
        str += ");"
      end
    end

    str.html_safe
  end

  def total_invoices_debt
    str = "<strong>Total: "
    total = current_organization.total_invoice_debt
    str += "#{total}"
    str += "</strong>"
    str.html_safe
  end

  def transaction_type_id(transaction)
    "##{transaction.get_type}"
  end
end
