# frozen_string_literal: true

class IncomeCategoriesStatisticSerializer
  attr_reader :organization, :statistic

  def initialize(organization, statistic)
    @organization = organization
    @statistic    = statistic[:data].dup
  end

  def as_json(_opts)
    statistic.shift # remove header
    data = statistic.map do |row|
      {
        name:  row[0],
        value: row[1],
      }
    end

    {
      data:     data,
      currency: Money.new(0, organization.default_currency).currency.as_json,
    }
  end
end
