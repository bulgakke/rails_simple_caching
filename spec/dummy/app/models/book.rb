class Book < ApplicationRecord
  belongs_to :author

  caches :author
end
