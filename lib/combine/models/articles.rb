# frozen_string_literal: true

module Combine
  module Models
    module Articles
      module_function

      def all
        @all ||= begin
          file = Combine::Config[:stores][:articles]
          Combine::Datasources::Csv.new(file).fetch do |row|
            Combine::Models::Article.new(row.to_h)
          end
        end
      end
    end

    class Article < Item
      def initialize(data)
        @data = {
          doi: sanitise_string(data['DOI']),
          title: sanitise_string(data['Title']),
          issn: format_issn(data['ISSN'])
        }
      end
    end
  end
end
