class MemberContext
  attr_reader :params

  def initialize(member, params = {})
    @member = member
    @params = params
  end

  private

  def method_missing(method, *args, &block)
    @member.send(method, *args, &block)
  end
end
