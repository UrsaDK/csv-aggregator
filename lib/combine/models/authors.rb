# frozen_string_literal: true

module Combine
  module Models
    module Authors
      module_function

      def all
        @all ||= begin
          file = Combine::Config[:stores][:authors]
          Combine::Datasources::Json.new(file).fetch do |row|
            Combine::Models::Author.new(row.to_h)
          end
        end
      end

      def find_by_doi(value)
        index = all.find_index { |i| i[:articles].include?(value.to_s) }
        all[index] unless index.nil?
      end
    end

    class Author < Item
      def initialize(data)
        @data = {
          name: sanitise_string(data['name']),
          articles: format_articles(data['articles'])
        }
      end

      private

      def format_articles(value)
        return value if value.is_a?(Array)
        [value]
      end
    end
  end
end
