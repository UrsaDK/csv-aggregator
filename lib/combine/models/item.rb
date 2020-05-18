# frozen_string_literal: true

require 'forwardable'

module Combine
  module Models
    class Item
      extend Forwardable

      attr_reader :data
      def_delegators :data, :[]

      private

      def sanitise_string(value)
        value.to_s.strip
      end

      def format_issn(value)
        num = value.split('-').join
        raise 'Invalid ISSN number' if num.length != 8
        "#{num[0..3]}-#{num[4..7]}"
      end
    end
  end
end
