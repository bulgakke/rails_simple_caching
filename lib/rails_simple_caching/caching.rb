# frozen_string_literal: true

module RailsSimpleCaching
  module Caching
    extend ActiveSupport::Concern

    included do
      extend ClassMethods
    end

    def update_cached(attribute)
      contents = public_send(attribute)
      key = "#{cache_key_with_version}/#{attribute}"
      success = Rails.cache.write(key, contents)
      success ? contents : false
    end

    # Updates all the cached attributes.
    # Returns true if every update is successful.
    def update_cache
      self.class.cached_attributes.map { |attr| update_cached(attr) }.none?(false)
    end
  end
end
