# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module InputObjects
      class AuditLogEntrySortInput < GraphQL::Schema::InputObject
        graphql_name "AuditLogEntrySortInput"
        description "Sort order for audit log entry queries."

        argument :field, Types::AuditLogEntrySortFieldEnum, required: true, description: "Field to sort by."
        argument :direction, Types::SortDirectionEnum, required: true, description: "Sort direction (ASC or DESC)."
      end
    end
  end
end
