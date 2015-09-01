require 'spec_helper'

describe 'invoices page list' do
  let(:user) { create :user }
  let(:org)  { create :organization, with_user: user }

  before do
    sign_in user
  end

  subject{ page }

  include_context 'invoices pagination'
  it_behaves_like 'paginateable' do
    let!(:list)      { create_list :invoice, invoices_count, organization: org }
    let(:list_class) { '.invoices' }
    let(:list_page)  { invoices_path }
  end
end
