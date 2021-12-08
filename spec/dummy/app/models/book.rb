class Book < ApplicationRecord
  belongs_to :author

  caching :author
end
