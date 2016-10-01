#### Intent
To create a simple, light-weight, easy to override, and easy to understand
boilerplate for standard controller actions.

#### Libraries
* Rails 5
* Active Model Serializers 0.10.2

#### Usage

```ruby
class ApplicationController < ActionController::API
  include GenericActions
end
```

Now the controller has support for the basic `index`, `show`, `create`,
`update`, and `destroy` actions. A `find` action that will return a single
resource or 404 instead of a collection like the `index` action is also
available.

Resources can be filtered and associations can be side-loaded in a single
request. Simple header-based pagination is also included.

The param-based filtering and side-loading was inspired by the
[JSONAPI spec](http://jsonapi.org/). The API for defining filters was inspired
by [JSONAPI::Resources](https://github.com/cerebris/jsonapi-resources).

##### Filtering

Creating a filter is done by using the `filter` method.

```
GET /customers?filter[first_name]=Joshua
```

```ruby
class CustomersController < ApplicationController
  filter :first_name
end
```

If your filter needs to do something besides check equality:

```ruby
class CustomersController < ApplicationController
  filter :first_name, -> (chain, value) do
    chain.where('first_name like ?', "%#{value}%")
  end
end
```

Filters are chained.

```
GET /customers?filter[first_name]=Joshua&filter[last_name]=Kappers
```

```ruby
class CustomersController < ApplicationController
  filter :last_name
  filter :first_name
end
```

##### Side-loading

Thanks to [Active Model Serializers](https://github.com/rails-api/active_model_serializers),
we can easily include association data in a single payload.

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

```
GET /customers?include=accounts,addresses
```
```
{
  ...,
  "accounts": [],
  "addresses": []
}
```

```
GET /account/1?include=customer.addresses,agency
```
```
{
  ...,
  "customer": {
    "addresses": [],
  },
  "agency": {}
}
```

###### Do I have to define a serializer for every resource?

Nah, Active Model Serializers will handle it if you don't. It seems that for
large payloads, defining a serializer speeds things up. I have not benchmarked
this to be certain that is the case.

##### Pagination

The actual method for applying the filter was lifted from
[Kaminari](https://github.com/amatsuda/kaminari).

Default page size is currently 50

`GET /customers?page=2&size=10`

```
HEADERS
  'X-Page' => 1,
  'X-Page-Size' => 10,
  'X-Page-Count' => 12,
  'X-Total' => 120
```

###### I don't like 50 as a page size >:(

Fine..

```
class ApplicationController
  include GenericActions

  def default_page_size
    25
  end
end
```

#### Why?
1. I was tired of duplicating the same controller boilerplate.
2. I used [JSONAPI::Resources](https://github.com/cerebris/jsonapi-resources) but...
3. ...I had some problems with the [JSONAPI spec](http://jsonapi.org/).

##### What problems did you have with the spec?

First, there is no support for creating multiple entities in a single request.
This was a huge problem for me and is a problem for
[many others](https://github.com/json-api/json-api/issues/795). While there is
a conversation and intent to include support in version 1.1, waiting is not an
option. This is especially true considering the conversation is over a year old with seemingly no solution in sight.

I have tried several libraries and workarounds. [My "favorite" workaround](https://github.com/jkappers/jsonapi-accepts-nested-attributes-for-kludge#what-was-your-intent)
was to use Rails `acccepts_nested_attributes_for` along with JSONAPI::Resources.

While this wasn't too bad on the API, I found that library support for consuming
the API is lacking.

I quickly realized I was sacrificing a lot of the productivity and duck-taping
together libraries that weren't designed to work together, all for the sake of
following a spec that doesn't add any value for my project or meet the needs of
my project.

Rails' standard serialization has served me well and doesn't slow me down.

##### Was there anything you liked about JSONAPI::Resources or the spec?

Yes! The side-loading of associations in a single request is very handy. The
filtering features were also very nice.

I want to move off of the spec and that library, but I want to keep those
features, so I replicated them here.
