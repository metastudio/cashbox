class OrganizationWizzard
  include Rails.application.routes.url_helpers

  def initialize(organization)
    @organization = organization
  end

  def ready?
    have_account? && have_categories?
  end

  def continue?
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
      new_category_organization_path
    else
      new_account_organization_path
    end
  end
end
