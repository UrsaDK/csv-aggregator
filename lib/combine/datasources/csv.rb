# frozen_string_literal: true

require 'csv'

module Combine
  module Datasources
    class Csv
      attr_reader :file
      attr_accessor :formatter, :data

      def initialize(file = nil)
        self.file = file unless file.nil?
      end

      def file=(path)
        unless File.exist?(path) && File.readable?(path)
          raise ArgumentError, "Missing or invalid file -- #{path}"
        end
        @file = path
      end

      def fetch
        [].tap do |results|
          CSV.foreach(file, Combine::Config[:csv]) do |row|
            row = yield(row) if block_given?
            results.push(row)
          end
        end
      end

      def to_s
        CSV.generate(Combine::Config[:csv]) do |csv|
          csv << data[0].keys
          data.each { |row| csv << row.values }
        end
      end
    end
  end
end
