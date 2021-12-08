# frozen_string_literal: true

require_relative "rails_simple_caching/version"
require_relative "rails_simple_caching/railtie" if defined?(Rails::Railtie)
require_relative "rails_simple_caching/caching"
require_relative "rails_simple_caching/caching/class_methods"

module RailsSimpleCaching
  class Error < StandardError; end
  # Your code goes here...
end
