module Types
  class SubscriptionType < Types::BaseObject
    include RailsAuditLog::Graphql::Subscriptions::AuditLogSubscriptionsMixin
  end
end
