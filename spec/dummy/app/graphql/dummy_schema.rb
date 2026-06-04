class DummySchema < GraphQL::Schema
  query Types::QueryType
  subscription Types::SubscriptionType
  use GraphQL::Subscriptions, broadcast: true
end
