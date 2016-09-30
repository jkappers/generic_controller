class AddressSerializer < ApplicationSerializer
  attributes :id
  belongs_to :customer
end
