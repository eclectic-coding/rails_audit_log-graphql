# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Types
      class DiffType < BaseObject
        graphql_name "AuditLogDiff"
        description "A single attribute change with before and after values."

        field :attribute, String, null: false, description: "The name of the changed attribute."
        field :from, GraphQL::Types::JSON, null: true, description: "Value before the change."
        field :to, GraphQL::Types::JSON, null: true, description: "Value after the change."

        def attribute
          object[:attribute]
        end

        def from
          object[:from]
        end

        def to
          object[:to]
        end
      end
    end
  end
end
