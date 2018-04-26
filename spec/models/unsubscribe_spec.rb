# == Schema Information
#
# Table name: unsubscribes
#
#  id         :integer          not null, primary key
#  email      :string
#  active     :boolean          default(FALSE)
#  token      :string
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Unsubscribe, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
