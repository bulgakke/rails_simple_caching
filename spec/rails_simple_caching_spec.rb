# frozen_string_literal: true

RSpec.describe RailsSimpleCaching do
  before :all do
    Rails.cache.clear
    Book.destroy_all
    Author.destroy_all
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
    book = Book.first
    cache_key = key(book, 'author')
    book.author
    expect(Rails.cache.read(cache_key)).to be_nil
    book.cached_author
    expect(Rails.cache.read(cache_key)).to_not be_nil
  end

  it "invalidates cache when the resource is updated in any way" do
    book = Book.first
    book.update_cached(:author)
    invalidated_cache_key = key(book, 'author')

    book.update(updated_at: Time.now)
    new_cache_key = key(book, 'author')

    expect(invalidated_cache_key).to_not eq(new_cache_key)
  end

  it "DOES NOT invalidate cache when the referenced attribute is updated" do
    author = Author.first
    author.update_cached(:books)
    author.books.first.destroy

    cached = author.cached_books
    queried = author.books.reload

    expect(cached).to_not eq(queried)
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
