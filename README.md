Technologies
* Rails 5
* Active Model Serializers 0.10.2

Usage

```ruby
class ApplicationController < ActionController::API
  include GenericActions
end
```

Now the controller has support for the basic `index`, `show`, `create`,
`update`, and `destroy` actions. A `find` action that will return a single
resource or 404 instead of a collection like the `index` action is also
available.

Filters

Setting up a filter is done using the `filter` class method.

```ruby
class CustomersController < ApplicationController
  filter :first_name
end
```

`GET /customers?filter[first_name]=Joshua`

If you don't to do something other than check for equality, you can override how
the filter is applied.

```ruby
class CustomersController < ApplicationController
  filter :first_name, -> (chain, value) do
    chain.where('first_name like ?', "%#{value}%")
  end
end
```

Filters are chained.

```ruby
class CustomersController < ApplicationController
  filter :last_name
  filter :first_name
end
```

`GET /customers?filter[first_name]=Joshua&filter[last_name]=Kappers`

Includes

Thanks to Active Model Serializers, we can include association data in a single
payload.

```ruby
class Customer
  has_many :accounts
  has_many :addresses
end

class Account
  belongs_to :customer
  belongs_to :agency
end

class Address
  belongs_to :customer
end

class Agency
  has_many :accounts
end
```

`GET /customers?include=accounts,addresses`

```
{
  ...,
  "accounts": [],
  "addresses": []
}
```
`GET /account/1?include=customer.addresses,agency`

```
{
  ...,
  "customer": {
    "addresses": [],
  },
  "agency": {}
}
```

Do I have to define a serializer for every resource?

Nah. Active Model Serializers will handle it.

Pagination

Default page size is currently 50

`GET /customers?page=2&size=10`

```
HEADERS
  'X-Page' => 1,
  'X-Page-Size' => 10,
  'X-Page-Count' => 12,
  'X-Total' => 120
```
