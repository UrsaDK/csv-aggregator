# frozen_string_literal: true

require 'optparse'

module Combine
  module Cli
    ENVIRONMENT_CONFIG = File.join(ROOT, 'config', "#{ENVIRONMENT}.yml")
    ENABLED_OPTIONS = %i[
      help_message
      output_format
      articles_store
      authors_store
      journals_store
    ].freeze

    class << self
      attr_reader :args, :options, :parser

      def start(args)
        Combine::Config.load(ENVIRONMENT_CONFIG)
        @args = pre_process_args(args)
        post_process_args
        Combine.journals_articles_authors
      end

      private

      def pre_process_args(args)
        OptionParser.new do |parser|
          parser.banner = "Usage: #{File.basename($PROGRAM_NAME)} [options]"
          @parser = parser
          ENABLED_OPTIONS.each { |method| send(method) }
        end.parse!(args)
      end

      def post_process_args
        find_store_in_args('articles')
        find_store_in_args('authors')
        find_store_in_args('journals')
      end

      def find_store_in_args(store)
        args.each do |arg|
          if File.basename(arg).match?(/^#{store}\W/i)
            save_store_path(store, arg)
            break
          end
        end
      end

      def save_store_path(store, path)
        Combine::Config[:stores][store.to_sym] = File.expand_path(path, ROOT)
      end

      def help_message
        parser.on('-h', '--help', 'Print help message') do
          puts parser
          exit
        end
      end

      def output_format
        parser.on('-f', '--format FORMAT', %w[json csv],
                  'Define output format: csv, json') do |format|
          Combine::Config[:output_format] = format
        end
      end

      def articles_store
        parser.on('--articles ARTICLES',
                  'Path to the articles store') do |path|
          save_store_path('articles', path)
        end
      end

      def authors_store
        parser.on('--authors AUTHORS',
                  'Path to the authors store') do |path|
          save_store_path('authors', path)
        end
      end

      def journals_store
        parser.on('--journals JOURNALS',
                  'Path to the journals store') do |path|
          save_store_path('journals', path)
        end
      end
    end
  end
end
