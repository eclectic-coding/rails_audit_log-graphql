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
        field :object_changes, Types::AuditLogJsonScalar, null: true
        field :object, Types::AuditLogJsonScalar, null: true, method_conflict_warning: false
        field :metadata, Types::AuditLogJsonScalar, null: true
        field :reason, String, null: true
        field :whodunnit_snapshot, String, null: true
        field :actor_type, String, null: true
        field :actor_id, GraphQL::Types::ID, null: true
        field :tenant_id, String, null: true
        field :created_at, GraphQL::Types::ISO8601DateTime, null: false
        field :actor, Types::ActorType, null: true,
          description: "The actor who performed this action, as a polymorphic reference."
        field :audited_resource, Types::AuditedResourceType, null: false,
          description: "The model type and ID of the record that was changed."
        field :diff, [Types::DiffType, null: false], null: true,
          description: "Structured per-attribute diffs parsed from objectChanges. Nil when no changes are recorded."

        def actor
          return nil if object.actor_id.nil? || object.actor_type.nil?
          {id: object.actor_id, type_name: object.actor_type}
        end

        def audited_resource
          {id: object.item_id, type_name: object.item_type}
        end

        def diff
          changes = object.object_changes
          return nil if changes.nil?
          changes.map { |attr, (from_val, to_val)| {attribute: attr, from: from_val, to: to_val} }
        end
      end
    end
  end
end
