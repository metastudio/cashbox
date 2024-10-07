module GenerateCsv
  extend ActiveSupport::Concern
  require 'csv'

  class_methods do
    def to_csv
      CSV.generate(col_sep: ',') do |csv|
        csv << column_names_for_title
        find_each do |item|
          csv << attributes_for_export(item)
        end
      end
    end

    def column_names_for_title
    end

    def column_names_for_row_csv
      column_names_for_title
    end

    private

    def attributes_for_export(item)
      column_names_for_row_csv.map {
        |column| item.send(column.underscore)
      }
    end
  end
end
