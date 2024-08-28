class Item < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :data, presence: true
end
