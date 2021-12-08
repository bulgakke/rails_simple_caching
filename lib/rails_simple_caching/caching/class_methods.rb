# frozen_string_literal: true

module RailsSimpleCaching
  module Caching
    module ClassMethods
      def cache_expires_in(time)
        @expire_time = time
      end

      def caching(attribute, expires_in: expire_time)
        @cached_attributes ||= []
        @cached_attributes << attribute

        # `cache_key_with_version` generates a string based on the
        # model's class name, `id`, and `updated_at` attributes.
        # This is a common convention and has the benefit of invalidating
        # the cache whenever the product is updated.
        define_method("cached_#{attribute}") do
          key = "#{cache_key_with_version}/#{attribute}"
          Rails.cache.fetch(key, expires_in: expires_in) do
            update_cached(attribute)
          end
        end
      end

      def cached_attributes
        @cached_attributes
      end

      private

      def expire_time
        @expire_time || Rails.configuration.default_expire_time
      end
    end
  end
end
