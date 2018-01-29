require 'rails_helper'

describe 'categories page' do
  let(:user) { create :user }
  let(:org)  { create :organization, with_user: user, without_categories: true }

  before do
    sign_in user
  end

  subject{ page }

  include_context 'categories pagination'
  it_behaves_like 'paginateable' do
    let!(:list)      { create_list(:category, categories_count, organization: org); org.categories.ordered}
    let(:list_class) { '.categories' }
    let(:list_page)  { categories_path }
  end
end
