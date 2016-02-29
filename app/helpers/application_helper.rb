module ApplicationHelper
  def nav_link(link_text, link_path)
    class_name = current_page?(link_path) ? 'active' : ''

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end

  def sortable(link_text, col_name)
    c = content_tag(:div, :class => 'text-wrapper') do
      link_text
    end

    c += content_tag(:div, :class => 'sort-links-wrapper') do
      sl = link_to '<i class="fa fa-sort-asc"></i>'.html_safe, params.merge(order: col_name, direction: 'asc'), class: 'sort-up'
      sl += '<br />'.html_safe
      sl += link_to '<i class="fa fa-sort-desc"></i>'.html_safe, params.merge(order: col_name, direction: 'desc'), class: 'sort-down'
    end

    return c.html_safe
  end
end
