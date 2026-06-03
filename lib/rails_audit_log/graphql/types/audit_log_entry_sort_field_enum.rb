# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Types
      class AuditLogEntrySortFieldEnum < GraphQL::Schema::Enum
        graphql_name "AuditLogEntrySortField"
        description "Fields available for sorting audit log entries."

        value "CREATED_AT", value: :created_at, description: "Sort by creation time."
      end
    end
  end
end
