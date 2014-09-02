require 'spec_helper'

describe UserPolicy do
  include_context 'organization with roles'

  subject { UserPolicy }

  permissions :edit_role? do
  end

  permissions :update_role? do
  end

end
