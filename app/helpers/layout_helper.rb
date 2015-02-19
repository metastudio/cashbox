module LayoutHelper
  def active_org(org)
    (org.id == current_organization.id ? 'active' : '')
  end
end
