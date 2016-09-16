class OrganizationWizzard

  def initialize(organization)
    @organization = organization
  end

  def ready?
    have_account? && have_categories?
  end

  def have_account?
    @organization.bank_accounts.any?
  end

  def have_categories?
    @organization.categories.any?
  end

  def step
    if have_account?
      'new_category'
    else
      'new_account'
    end
  end
end
