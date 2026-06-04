class DummySchema < GraphQL::Schema
  include RailsAuditLog::Graphql::SchemaPlugin

  query Types::QueryType
  subscription Types::SubscriptionType
  use GraphQL::Subscriptions, broadcast: true
end
