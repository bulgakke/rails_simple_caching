# frozen_string_literal: true

RSpec.describe RailsSimpleCaching do
  before :all do
    Rails.cache.clear
    a = Author.create(name: "Some Author")
    Book.create(title: "Some Book", author: a)
    Book.create(title: "Another Book", author: a)

    if Rails.cache.is_a? ActiveSupport::Cache::NullStore
      raise "Rails cache is not configured. Check `config.cache_store` in development.rb"
    end
  end

  it "has a version number" do
    expect(RailsSimpleCaching::VERSION).not_to be nil
  end

  it "works in a dummy Rails environment" do
    expect(Rails.application).to be_truthy
  end

  it "doesn't break when called and returns the attribute" do
    cached = Author.first.cached_books
    queried = Author.first.books
    expect(cached).to eq(queried)
  end

  it "stores values in cache" do
    b = Book.first
    key = b.cache_key_with_version + '/author'
    b.author
    expect(Rails.cache.read(key)).to be_nil
    b.cached_author
    expect(Rails.cache.read(key)).to_not be_nil
  end

  it "invalidates cache when the resource is updated" do
    b = Book.first
    a = b.cached_author
    old_name = a.name
    a.update(name: old_name.reverse)
    queried = b.author
    cached = b.cached_author

    expect(queried.name).to eq(old_name.reverse)
    expect(queried).to eq(cached)
  end

  it "DOES NOT invalidate cache when the referenced attribute is updated" do
    cached1 = Author.first.cached_books
    Book.first.destroy
    cached2 = Author.first.cached_books
    expect(cached1).to eq(cached2)
  end

  it "works with other methods" do
    a = Author.first
    initial_counter = a.counter
    result1 = a.cached_expensive_method
    after_calling = a.counter
    expect(after_calling).to eq(initial_counter + 1)

    result2 = a.cached_expensive_method
    expect(result1).to eq(result2)
    after_caching = a.counter
    expect(after_calling).to eq(after_caching)
  end

  it "does not generate 'cached_' methods unless explicitly told to" do
    a = Author.first
    expect { a.cached_name }.to raise_error(NoMethodError)
    Author.caches :name
    expect(a.cached_name).to eq(a.name)
  end
end
