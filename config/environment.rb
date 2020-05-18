# frozen_string_literal: true

ROOT = File.expand_path('..', __dir__)
ENVIRONMENT = (ENV['ENVIRONMENT'] || 'development').tap do |env|
  case File.basename($PROGRAM_NAME)
  when 'rake'
    ENV['RAKE_ENV'] = env
  when 'rackup'
    ENV['RACK_ENV'] = env
  end
end

# Prepend directory to the LOAD_PATH and process all files within it
# recursively. Files are required if the supplied block return true.
# @yield [file, path_elements]
def require_dir(*path_elements)
  dir = File.join(path_elements)
  $LOAD_PATH.unshift(dir)
  Dir.glob(File.join('**', '*.rb'), base: dir) do |file|
    require file if block_given? && yield(file, file.split(File::SEPARATOR))
  end
end

require 'pry' if ENVIRONMENT == 'development'
