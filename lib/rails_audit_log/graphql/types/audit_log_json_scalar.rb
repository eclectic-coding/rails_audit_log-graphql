# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Types
      class AuditLogJsonScalar < GraphQL::Schema::Scalar
        graphql_name "AuditLogJson"
        description "A JSON blob stored on an audit log entry (objectChanges, object, or metadata)."

        def self.coerce_input(value, _ctx)
          value.is_a?(Hash) ? value : JSON.parse(value)
        rescue JSON::ParserError
          raise GraphQL::CoercionError, "#{value.inspect} is not valid JSON"
        end

        def self.coerce_result(value, _ctx)
          value
        end
      end
    end
  end
end
