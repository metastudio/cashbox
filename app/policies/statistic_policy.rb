# frozen_string_literal: true

class StatisticPolicy < ApplicationPolicy
  def access?
    !!member
  end

  alias balance? access?
end
