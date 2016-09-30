class AccountsController < ApplicationController
  filter :customer_id
  filter :first_name, -> (chain, value) do
    chain.joins(:customer).where('customers.first_name like ?', "%#{value}%")
  end
end
