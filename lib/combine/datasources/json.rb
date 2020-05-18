# frozen_string_literal: true

require 'json'

module Combine
  module Datasources
    class Json
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
        source = File.read(file)
        JSON.parse(source).each_with_object([]) do |row, results|
          row = yield(row) if block_given?
          results.push(row)
        end
      end

      def to_s
        data.to_json
      end
    end
  end
end
