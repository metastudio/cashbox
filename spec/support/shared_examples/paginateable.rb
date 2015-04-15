shared_examples_for "paginateable" do
  describe 'page' do
    before do
      visit list_page
    end

    it "lists first page items" do
      list.first(paginated).each do |item|
        within list_class do
          expect(page).to have_css("#{item_id_prefix}#{item.id}")
        end
      end
    end

    it "doesnt list second page items" do
      list.last(5).each do |item|
        within list_class do
          expect(page).to_not have_css("#{item_id_prefix}#{item.id}")
        end
      end
    end

    context "switch to last page" do
      before do
        within '.pagination' do
          click_on 'Last'
        end
      end

      it "doesnt list first page items" do
        list.first(paginated).each do |item|
          within list_class do
            expect(page).to_not have_css("#{item_id_prefix}#{item.id}")
          end
        end
      end

      it "lists 5 last items" do
        list.last(5).each do |item|
          within list_class do
            expect(page).to have_css("#{item_id_prefix}#{item.id}")
          end
        end
      end
    end
  end
end
