class BookDomain < ApplicationRecord
  belongs_to :book
  belongs_to :domain
end
