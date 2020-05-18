# frozen_string_literal: true

module Combine
  module Models
    module Journals
      module_function

      def all
        @all ||= begin
          file = Combine::Config[:stores][:journals]
          Combine::Datasources::Csv.new(file).fetch do |row|
            Combine::Models::Journal.new(row.to_h)
          end
        end
      end

      def find_by_issn(value)
        index = all.find_index { |i| i[:issn] == value }
        all[index] unless index.nil?
      end
    end

    class Journal < Item
      def initialize(data)
        @data = {
          title: sanitise_string(data['Title']),
          issn: format_issn(data['ISSN'])
        }
      end
    end
  end
end
