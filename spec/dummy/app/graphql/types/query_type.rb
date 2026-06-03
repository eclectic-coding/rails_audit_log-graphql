module Types
  class QueryType < Types::BaseObject
    include RailsAuditLog::Graphql::Queries::AuditLogEntriesQueryMixin
  end
end
