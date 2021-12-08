class Author < ApplicationRecord
  has_many :books

  caches :books
  caches :expensive_method

  def counter
    @counter ||= 0
  end

  def method_with_an(argument)
    argument.to_s.reverse
  end

  def expensive_method
    @counter ||= 0
    @counter += 1

    1 + 2 + 3
  end
end
