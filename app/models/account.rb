class Account < ApplicationRecord
  belongs_to :customer
  belongs_to :agency
end
