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
            argument :for_tenant, String, required: false,
              description: "Scope to a specific tenant ID. Overrides auto-tenant when RailsAuditLog.current_tenant is configured."
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
            argument :touching, String, required: false, description: "Filter to entries that changed a specific attribute (matches object_changes keys)."
            argument :order_by, RailsAuditLog::Graphql::InputObjects::AuditLogEntrySortInput, required: false, description: "Sort order. Defaults to CREATED_AT DESC."
            argument :for_tenant, String, required: false,
              description: "Scope to a specific tenant ID. Overrides auto-tenant when RailsAuditLog.current_tenant is configured."
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
            argument :touching, String, required: false, description: "Filter to entries that changed a specific attribute (matches object_changes keys)."
            argument :order_by, RailsAuditLog::Graphql::InputObjects::AuditLogEntrySortInput, required: false, description: "Sort order. Defaults to CREATED_AT DESC."
            argument :for_tenant, String, required: false,
              description: "Scope to a specific tenant ID. Overrides auto-tenant when RailsAuditLog.current_tenant is configured."
          end

          base.field(
            :audit_log_reify,
            GraphQL::Types::JSON,
            null: true,
            description: "Reconstruct the attribute state of a record at a given point in time. Returns nil when no entry exists at or before `at`, or when the record was destroyed.",
            resolver_method: :resolve_audit_log_reify
          ) do
            argument :item_type, String, required: true, description: "The audited model class name."
            argument :item_id, GraphQL::Types::ID, required: true, description: "The audited record ID."
            argument :at, GraphQL::Types::ISO8601DateTime, required: true, description: "Reconstruct state as of this time."
          end

          base.field(
            :audit_log_entries_count,
            GraphQL::Types::Int,
            null: false,
            description: "Count audit log entries with optional filters. Respects auto-tenant when RailsAuditLog.current_tenant is configured.",
            resolver_method: :resolve_audit_log_entries_count
          ) do
            argument :event, String, required: false, description: "Filter by event type (create, update, destroy)."
            argument :item_type, String, required: false, description: "Filter by audited model class name."
            argument :since, GraphQL::Types::ISO8601DateTime, required: false, description: "Count entries created at or after this time."
          end
        end

        def resolve_audit_log_entry(id:, for_tenant: nil)
          check_authentication!
          tenant_id = for_tenant || RailsAuditLog.current_tenant&.call
          base = tenant_id ? RailsAuditLog::AuditLogEntry.for_tenant(tenant_id) : RailsAuditLog::AuditLogEntry
          base.find_by(id: id)
        end

        def resolve_audit_log_entries(event: nil, item_type: nil, item_id: nil, actor_id: nil, since: nil, until_time: nil, touching: nil, order_by: nil, for_tenant: nil, page: 1, per_page: 25)
          check_authentication!
          scope = build_scope(event: event, item_type: item_type, item_id: item_id, actor_id: actor_id, since: since, until_time: until_time, touching: touching, order_by: order_by, for_tenant: for_tenant)
          scope.limit(per_page).offset((page - 1) * per_page)
        end

        def resolve_audit_log_entries_connection(event: nil, item_type: nil, item_id: nil, actor_id: nil, since: nil, until_time: nil, touching: nil, order_by: nil, for_tenant: nil)
          check_authentication!
          build_scope(event: event, item_type: item_type, item_id: item_id, actor_id: actor_id, since: since, until_time: until_time, touching: touching, order_by: order_by, for_tenant: for_tenant)
        end

        def resolve_audit_log_reify(item_type:, item_id:, at:)
          check_authentication!
          entry = RailsAuditLog::AuditLogEntry
            .where(item_type: item_type, item_id: item_id)
            .where("created_at <= ?", at)
            .order(created_at: :desc, id: :desc)
            .first
          return nil if entry.nil? || entry.event == "destroy"
          to_attrs = (entry.object_changes || {}).transform_values { |v| v[1] }
          entry.object.present? ? entry.object.merge(to_attrs) : to_attrs
        end

        def resolve_audit_log_entries_count(event: nil, item_type: nil, since: nil)
          check_authentication!
          scope = RailsAuditLog::AuditLogEntry.all
          scope = scope.where(event: event) if event
          scope = scope.where(item_type: item_type) if item_type
          scope = scope.where("created_at >= ?", since) if since
          tenant_id = RailsAuditLog.current_tenant&.call
          scope = scope.for_tenant(tenant_id) if tenant_id
          scope.count
        end

        private

        def build_scope(event: nil, item_type: nil, item_id: nil, actor_id: nil, since: nil, until_time: nil, touching: nil, order_by: nil, for_tenant: nil)
          sort_field = order_by&.field || :created_at
          sort_direction = order_by&.direction || :desc
          scope = RailsAuditLog::AuditLogEntry.order(sort_field => sort_direction)
          scope = scope.where(event: event) if event
          scope = scope.where(item_type: item_type) if item_type
          scope = scope.where(item_id: item_id) if item_id
          scope = scope.where(actor_id: actor_id) if actor_id
          scope = scope.where("created_at >= ?", since) if since
          scope = scope.where("created_at <= ?", until_time) if until_time
          if touching
            safe = ActiveRecord::Base.sanitize_sql_like(touching)
            scope = scope.where("object_changes LIKE ?", "%\"#{safe}\":%")
          end
          tenant_id = for_tenant || RailsAuditLog.current_tenant&.call
          scope = scope.for_tenant(tenant_id) if tenant_id
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
