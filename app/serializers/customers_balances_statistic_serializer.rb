# frozen_string_literal: true

class CustomersBalancesStatisticSerializer
  attr_reader :organization, :statistic

  def initialize(organization, statistic)
    @organization = organization
    if statistic
      @statistic = statistic[:data].dup
      @statistic.shift # remove header
      @statistic.sort_by!{ |name, _income, _expense| name }
    else
      @statistic = []
    end
  end

  def as_json(_opts)
    data = statistic.map do |row|
      {
        name:    row[0],
        income:  row[1],
        expense: row[2],
      }
    end

    {
      data:     data,
      currency: Money.new(0, organization.default_currency).currency.as_json,
    }
  end
end
