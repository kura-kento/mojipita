class Player < ApplicationRecord
  validates :name, presence: true
  validates :name,{uniqueness: true}
  validates :name,length:{maximum: 10}
end
