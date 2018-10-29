# frozen_string_literal: true

class BalanceStatisticSerializer
  attr_reader :organization, :statistic

  def initialize(organization, statistic)
    @organization = organization
    @statistic    = statistic[:data].dup
  end

  def as_json(_opts)
    statistic.shift # remove header
    data = statistic.map do |row|
      {
        month:   row[0],
        income:  row[1],
        expense: row[2],
        total:   row[3],
      }
    end

    {
      data:     data,
      currency: Money.new(0, organization.default_currency).currency.as_json,
    }
  end
end
