# frozen_string_literal: true

class TransactionPolicy < ApplicationPolicy
  alias transaction record

  def index?
    !!member
  end

  def create?
    !!member
  end

  def create_transfer?
    create?
  end

  def access?
    return false if member&.organization_id.blank? || transaction.organization.blank?

    member.organization_id == transaction.organization.id
  end

  alias show?    access?
  alias update?  access?
  alias destroy? access?
end
