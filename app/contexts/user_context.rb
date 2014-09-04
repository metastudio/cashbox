class UserContext
  attr_reader :params

  def initialize(user_organization, params = {})
    @user_organization = user_organization
    @params = params
  end

  private

  def method_missing(method, *args, &block)
    @user_organization.send(method, *args, &block)
  end
end
