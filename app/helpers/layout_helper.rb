module LayoutHelper
  def active_org(org)
    (org.id == current_organization.id ? 'active' : '')
  end

  def active_sett(sett)
    params[:controller] == sett ? 'list-group-item active' : 'list-group-item'
  end
end
