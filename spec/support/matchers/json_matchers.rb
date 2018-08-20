# frozen_string_literal: true

module JSONMatcherHelpers
  def json_field(field)
    field.is_a?(Hash) ? field.first.first : field
  end

  def obj_field(field)
    field.is_a?(Hash) ? field.first.last : field
  end

  def json_value(json, field)
    value = json.send(json_field(field))
    value.is_a?(RecursiveOpenStruct) ? value.to_h : value
  end

  def obj_value(obj, field)
    obj.send(obj_field(field)).as_json
  end

  def match_all_fields?(object, json, fields)
    fields.map do |f|
      json_value(json, f) == obj_value(object, f)
    end.all?
  end

  def description_for(object, json_type = nil)
    %(be#{(json_type ? " #{json_type} " : ' ')}json for #{object.class.name} "#{object}")
  end

  def failure_messsages(object, json, fields)
    fields.map{ |f| message(json, object, f) }.compact.join("\n")
  end

  def message(json, object, field)
    %(expected field "#{json_field(field)}" to be #{obj_value(object, field).inspect} but is #{json_value(json, field).inspect}) if json_value(json, field) != obj_value(object, field)
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
    [
      :id,
      :starts_at,
      :ends_at,
      :amount,
      :sent_at,
      :paid_at,
      :number,
      :customer_name,
      { is_completed: :completed? },
      { is_overdue: :overdue? },
    ].freeze
  end

  match{ |j| match_all_fields?(p, j, fields) }
  failure_message{ |j| failure_messsages(p, j, fields) }
  description{ description_for(p, 'short') }
end
