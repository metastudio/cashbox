# frozen_string_literal: true

class InvoicePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless member

      scope.where(organization_id: member.organization_id)
    end
  end

  alias invoice record

  def access?
    return false unless member
    return false unless invoice
    return false if member.organization_id.blank?
    return false if invoice.organization_id.blank?

    member.organization_id == invoice.organization_id
  end

  def index?
    !!member
  end

  alias show?    access?
  alias create?  access?
  alias destroy? access?

  def permitted_attributes
    [
      :customer_id, :customer_name, :starts_at, :ends_at, :currency, :amount,
      :sent_at, :paid_at, :number,
      invoice_items_attributes: %i[
        id customer_id customer_name amount date hours description _destroy
      ]
    ]
  end
end
