# frozen_string_literal: true

class CustomersByMonthsStatisticSerializer
  attr_reader :organization, :statistic

  def initialize(organization, statistic)
    @organization = organization
    @statistic    = statistic[:data].dup
  end

  def as_json(_opts)
    header = statistic.shift[1..-2]
    data = statistic.map do |row|
      customers = {}
      header.each_with_index{ |customer_name, idx| customers.merge!({ customer_name => row[idx + 1] }) }
      {
        month: row[0],
      }.merge(customers)
    end

    {
      header:   header,
      data:     data,
      currency: Money.new(0, organization.default_currency).currency.as_json,
    }
  end
end
