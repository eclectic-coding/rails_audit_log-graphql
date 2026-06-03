# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Types
      class AuditLogEntryType < BaseObject
        graphql_name "AuditLogEntry"
        description "A single audited event on an ActiveRecord model."

        field :id, GraphQL::Types::ID, null: false
        field :event, String, null: false
        field :item_type, String, null: false
        field :item_id, GraphQL::Types::ID, null: false
        field :object_changes, GraphQL::Types::JSON, null: true
        field :object, GraphQL::Types::JSON, null: true, method_conflict_warning: false
        field :metadata, GraphQL::Types::JSON, null: true
        field :reason, String, null: true
        field :whodunnit_snapshot, String, null: true
        field :actor_type, String, null: true
        field :actor_id, GraphQL::Types::ID, null: true
        field :tenant_id, String, null: true
        field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      end
    end
  end
end
