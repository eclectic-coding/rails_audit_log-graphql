# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Queries
      module AuditLogEntriesQueryMixin
        def self.included(base)
          base.field(
            :audit_log_entry,
            RailsAuditLog::Graphql::Types::AuditLogEntryType,
            null: true,
            description: "Fetch a single audit log entry by ID. Returns nil if not found.",
            resolver_method: :resolve_audit_log_entry
          ) do
            argument :id, GraphQL::Types::ID, required: true,
              description: "ID of the audit log entry."
          end

          base.field(
            :audit_log_entries,
            [RailsAuditLog::Graphql::Types::AuditLogEntryType, null: false],
            null: false,
            description: "List audit log entries with optional filters. Offset-paginated.",
            resolver_method: :resolve_audit_log_entries
          ) do
            argument :event, String, required: false, description: "Filter by event type (create, update, destroy)."
            argument :item_type, String, required: false, description: "Filter by audited model class name."
            argument :item_id, GraphQL::Types::ID, required: false, description: "Filter by audited record ID."
            argument :actor_id, GraphQL::Types::ID, required: false, description: "Filter by actor ID."
            argument :since, GraphQL::Types::ISO8601DateTime, required: false, description: "Return entries created at or after this time."
            argument :until, GraphQL::Types::ISO8601DateTime, required: false, as: :until_time, description: "Return entries created at or before this time."
            argument :page, GraphQL::Types::Int, required: false, default_value: 1, description: "Page number (1-based)."
            argument :per_page, GraphQL::Types::Int, required: false, default_value: 25, description: "Number of results per page."
          end

          base.field(
            :audit_log_entries_connection,
            RailsAuditLog::Graphql::Types::AuditLogEntryType.connection_type,
            null: false,
            description: "List audit log entries with optional filters. Cursor-paginated (Relay connection).",
            resolver_method: :resolve_audit_log_entries_connection
          ) do
            argument :event, String, required: false, description: "Filter by event type (create, update, destroy)."
            argument :item_type, String, required: false, description: "Filter by audited model class name."
            argument :item_id, GraphQL::Types::ID, required: false, description: "Filter by audited record ID."
            argument :actor_id, GraphQL::Types::ID, required: false, description: "Filter by actor ID."
            argument :since, GraphQL::Types::ISO8601DateTime, required: false, description: "Return entries created at or after this time."
            argument :until, GraphQL::Types::ISO8601DateTime, required: false, as: :until_time, description: "Return entries created at or before this time."
          end
        end

        def resolve_audit_log_entry(id:)
          check_authentication!
          RailsAuditLog::AuditLogEntry.find_by(id: id)
        end

        def resolve_audit_log_entries(event: nil, item_type: nil, item_id: nil, actor_id: nil, since: nil, until_time: nil, page: 1, per_page: 25)
          check_authentication!
          scope = build_scope(event: event, item_type: item_type, item_id: item_id, actor_id: actor_id, since: since, until_time: until_time)
          scope.limit(per_page).offset((page - 1) * per_page)
        end

        def resolve_audit_log_entries_connection(event: nil, item_type: nil, item_id: nil, actor_id: nil, since: nil, until_time: nil)
          check_authentication!
          build_scope(event: event, item_type: item_type, item_id: item_id, actor_id: actor_id, since: since, until_time: until_time)
        end

        private

        def build_scope(event: nil, item_type: nil, item_id: nil, actor_id: nil, since: nil, until_time: nil)
          scope = RailsAuditLog::AuditLogEntry.order(created_at: :desc)
          scope = scope.where(event: event) if event
          scope = scope.where(item_type: item_type) if item_type
          scope = scope.where(item_id: item_id) if item_id
          scope = scope.where(actor_id: actor_id) if actor_id
          scope = scope.where("created_at >= ?", since) if since
          scope = scope.where("created_at <= ?", until_time) if until_time
          scope
        end

        def check_authentication!
          auth = RailsAuditLog.authenticate
          return unless auth
          raise GraphQL::ExecutionError, "Unauthorized" unless auth.call(context)
        end
      end
    end
  end
end
