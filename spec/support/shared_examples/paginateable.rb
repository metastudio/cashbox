shared_examples_for 'paginateable' do
  describe 'page', order: :defined do
    before do
      visit list_page
    end

    context 'switch to first page' do
      before do
        within '.pagination' do
          click_on '1'
        end
      end

      it 'lists first page items' do
        list.first(paginated).each do |item|
          within list_class do
            expect(page).to have_css("##{dom_id(item)}")
          end
        end
      end

      it 'doesnt list second page items' do
        list.last(paginated).each do |item|
          within list_class do
            expect(page).to_not have_css("##{dom_id(item)}")
          end
        end
      end
    end

    context 'switch to last page' do
      before do
        within '.pagination' do
          click_on 'Last'
        end
      end

      it 'doesnt list first page items' do
        list.first(paginated).each do |item|
          within list_class do
            expect(page).to_not have_css("##{dom_id(item)}")
          end
        end
      end

      it 'lists last page items' do
        list.last(paginated).each do |item|
          within list_class do
            expect(page).to have_css("##{dom_id(item)}")
          end
        end
      end
    end
  end
end
