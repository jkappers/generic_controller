class AccountSerializer < ApplicationSerializer
  attributes :id
  attributes :customer_id
  belongs_to :customer
  belongs_to :agency
end
