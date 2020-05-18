# frozen_string_literal: true

require 'yaml'

module Combine
  module Config
    DEFAULT_CONFIG = File.join(ROOT, 'config', 'defaults.yml')

    class << self
      attr_reader :config

      def [](key)
        config[key]
      end

      def []=(key, value)
        config[key.to_sym] = value
      end

      def load(*config)
        custom_config = config.empty? ? nil : File.join(config)
        @config = merge(DEFAULT_CONFIG, custom_config)
      end

      private

      def merge(default_config, custom_config)
        defaults = parse(default_config)
        return defaults unless custom_config
        defaults.merge(parse(custom_config))
      end

      def parse(config_file)
        symbolise_keys(YAML.load_file(config_file))
      end

      # rubocop: disable Metrics/MethodLength
      def symbolise_keys(object)
        return object.map { |i| symbolise_keys(i) } if object.is_a?(Array)
        return object unless object.is_a?(Hash)
        object.each_with_object({}) do |(k, v), result|
          key = k.is_a?(String) ? k.to_sym : k
          value = case v
                  when Hash then symbolise_keys(v)
                  when Array then v.map { |i| symbolise_keys(i) }
                  else v
                  end
          result[key] = value
        end
      end
      # rubocop: enable Metrics/MethodLength
    end
  end
end
