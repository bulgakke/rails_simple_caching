class Author < ApplicationRecord
  has_many :books
  has_many :publishers, through: :books

  caching :books
  caching :expensive_method

  def counter
    @counter ||= 0
  end

  def expensive_method
    @counter ||= 0
    @counter += 1

    1 + 2 + 3
  end
end
