# frozen_string_literal: true

class AuthenticateUserService < BaseService
  attr_reader :email, :password

  def initialize(email, password)
    @email    = email
    @password = password
  end

  def perform
    raise Api::V1::BaseController::AuthorizationError unless user&.authenticate(password)
    return error(I18n.t('devise.failure.locked')) if user.locked?

    return ok(auth_token)
  end

  private

  def auth_token
    Knock::AuthToken.new(payload: { sub: user.id })
  end

  def user
    User.find_by(email: email)
  end
end
