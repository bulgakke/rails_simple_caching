module RailsSimpleCaching
  class Railtie < ::Rails::Railtie
    config.default_expire_time = 24.hours

    initializer 'rails_simple_caching.include_caching_concern' do
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.include Caching
      end
    end
  end
end
