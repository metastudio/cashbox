class OrganizationWizzard
  include Rails.application.routes.url_helpers

  def initialize(organization)
    @organization = organization
  end

  def ready?
    have_account? && have_categories?
  end

  def not_ready?
    not ready?
  end

  def have_account?
    @organization.bank_accounts.any?
  end

  def have_categories?
    @organization.categories.any?
  end

  def step_url
    if have_account?
      new_category_organization_path(@organization.id)
    else
      new_account_organization_path(@organization.id)
    end
  end
end
