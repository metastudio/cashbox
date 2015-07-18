require 'spec_helper'

describe 'customers page list' do
  let(:user) { create :user }
  let(:org)  { create :organization, with_user: user }

  before do
    sign_in user
  end

  subject{ page }

  include_context 'customers pagination'
  it_behaves_like 'paginateable' do
    let!(:list)      { create_list :customer, customers_count, organization: org }
    let(:list_class) { '.customers' }
    let(:list_page)  { customers_path }
  end
end
