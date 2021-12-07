module RailsSimpleCache
  class Railtie < ::Rails::Railtie
    config.simple_cache.default_expire_time = 24.hours

    initializer 'rails_simple_cache.include_caching_concern' do
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.include Caching
      end
    end
  end
end
