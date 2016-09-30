class CustomerSerializer < ApplicationSerializer
  attributes :id
  has_many :accounts
  has_many :addresses
end
