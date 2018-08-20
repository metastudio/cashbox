# frozen_string_literal: true

module JSONMatcherHelpers
  def match_all_fields?(object, json, fields)
    fields.map do |f|
      json_value = json.send(f)
      json_value = json_value.to_h if json_value.is_a?(RecursiveOpenStruct)
      json_value == object.send(f).as_json
    end.all?
  end

  def description_for(object, json_type = nil)
    %(be#{(json_type ? " #{json_type} " : ' ')}json for #{object.class.name} "#{object}")
  end

  def failure_messsages(object, json, fields)
    fields.map{ |f| message(json, object, f) }.compact.join("\n")
  end

  def message(json, object, field)
    %(expected field "#{field}" to be #{object.send(field).as_json.inspect} but is #{json.send(field).inspect}) if json.send(field) != object.send(field).as_json
  end
end

RSpec::Matchers.define :be_short_category_json do |p|
  include JSONMatcherHelpers

  def fields
    %i[id name type].freeze
  end

  match{ |j| match_all_fields?(p, j, fields) }
  failure_message{ |j| failure_messsages(p, j, fields) }
  description{ description_for(p, 'short') }
end

RSpec::Matchers.define :be_short_bank_account_json do |p|
  include JSONMatcherHelpers

  def fields
    %i[id name currency].freeze
  end

  match{ |j| match_all_fields?(p, j, fields) }
  failure_message{ |j| failure_messsages(p, j, fields) }
  description{ description_for(p, 'short') }
end

RSpec::Matchers.define :be_short_customer_json do |p|
  include JSONMatcherHelpers

  def fields
    %i[id name].freeze
  end

  match{ |j| match_all_fields?(p, j, fields) }
  failure_message{ |j| failure_messsages(p, j, fields) }
  description{ description_for(p, 'short') }
end

RSpec::Matchers.define :be_short_invoice_json do |p|
  include JSONMatcherHelpers

  def fields
    %i[id starts_at ends_at amount sent_at paid_at number customer_name].freeze
  end

  match{ |j| match_all_fields?(p, j, fields) }
  failure_message{ |j| failure_messsages(p, j, fields) }
  description{ description_for(p, 'short') }
end
