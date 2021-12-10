# RailsSimpleCaching

A simple wrapper around Rails built-in caching. Provides Rails-like macros to generate `cached_` versions of your methods. The original goal was to reduce DB queries, but it works with any methods you define (as long as they don't take any arguments, though it's doable to make it work for methods with arguments, too).
How Rails caching works: https://guides.rubyonrails.org/caching_with_rails.html#low-level-caching
https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html

To read more on what this does and doesn't do, refer to the [spec file](spec/rails_simple_caching_spec.rb).

https://github.com/igorkasyanchuk/rails_cached_method is the only gem of a similar caliber that does kind of the same thing. That one's functionality is wider, but it does a little bit too much for my taste.

## Example of usage:

```ruby
class Author < ApplicationRecord
  has_many :books

  cache_expires_in 96.hours
  caches :books
  caches :expensive_method, expires_in: 2.hours

  def expensive_method
    SomeExternalAPIService.call(self)
    do_something_else
  end
end
```

The above is equivalent to:
```ruby
class Author < ApplicationRecord
  has_many :books

  def expensive_method
    SomeExternalAPIService.call(self)
    do_something_else
  end

  def cached_books
    Rails.cache.fetch("#{cache_key_with_version}/books", expires_in: 96.hours) do
      books
    end
  end

  def cached_expensive_method
    Rails.cache.fetch("#{cache_key_with_version}/expensive_method", expires_in: 2.hours) do
      expensive_method
    end
  end
end
```

Rails caching won't work in development by default; run `rails dev:cache` in terminal.

## Cache expiration time
Use these methods for setting up expiration time (how long until the data is deleted from the cache store). All of them expect a `ActiveSupport::Duration` argument (`24.hours`, `10.minutes` etc.)
The precedence goes:

1. `:expires_in` keyword argument.
2. `cache_expires_in` class method. Sets default expiration time for all `caches` macros in the model class. Will only work on macros that are declared below it, for example:

```ruby
caches :something # Cache will still expire after default time
cache_expires_in 2.minutes
caches :something_else # Will expire in 2 minutes
cache_expires_in 3.hours
caches :another_something # Will expire in 3 hours
```
3. `Rails.configuration.default_expire_time`: global default for all models. Set to `24.hours` by default. Set it to your liking in `config/application.rb` or in `config/environments/`

## Cache invalidation
The cache is invalidated whenever an object with a `cached_` method has its `updated_at` value changed (because [this method](https://api.rubyonrails.org/classes/ActiveRecord/Integration.html#method-i-cache_key_with_version) is used to form the key by which the data is fetched). The data is not deleted from the store, it just won't be fetched the next time you call the method.

`# TODO: write some more about cache invalidation`


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails_simple_caching'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rails_simple_caching


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bulgakke/rails_simple_caching.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
