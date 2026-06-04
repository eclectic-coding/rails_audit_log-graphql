# frozen_string_literal: true

require "graphql"
require_relative "graphql/version"
require_relative "graphql/types/base_object"
require_relative "graphql/types/base_subscription"
require_relative "graphql/types/audit_log_json_scalar"
require_relative "graphql/types/diff_type"
require_relative "graphql/types/actor_type"
require_relative "graphql/types/audited_resource_type"
require_relative "graphql/types/audit_log_entry_type"
require_relative "graphql/types/sort_direction_enum"
require_relative "graphql/types/audit_log_entry_sort_field_enum"
require_relative "graphql/input_objects/audit_log_entry_sort_input"
require_relative "graphql/sources/record_by_id_source"
require_relative "graphql/queries/audit_log_entries_query_mixin"
require_relative "graphql/subscriptions/audit_log_entry_created"
require_relative "graphql/subscriptions/audit_log_subscriptions_mixin"
require_relative "graphql/subscriptions/broadcaster"
require_relative "graphql/schema_plugin"

# The top-level namespace for the rails_audit_log gem.
module RailsAuditLog
  # GraphQL API layer for rails_audit_log.
  #
  # Provides ready-made types, queries, subscriptions, and test helpers for
  # exposing {https://github.com/eclectic-coding/rails_audit_log rails_audit_log}
  # audit log entries through a graphql-ruby schema.
  #
  # == Configuration
  #
  # Override query-protection defaults in an initializer:
  #
  #   RailsAuditLog::Graphql.max_complexity      = 500
  #   RailsAuditLog::Graphql.max_depth           = 15
  #   RailsAuditLog::Graphql.default_max_page_size = 50
  #
  # These values are picked up by {SchemaPlugin} when it is included in the
  # host schema.
  module Graphql
    class Error < StandardError; end

    @max_complexity = 200
    @max_depth = 10
    @default_max_page_size = 25

    class << self
      # Maximum allowed query complexity score.
      # Queries whose field-complexity sum exceeds this value are rejected.
      # Default: +200+.
      # @return [Integer]
      attr_accessor :max_complexity

      # Maximum allowed query depth.
      # Queries nested deeper than this value are rejected.
      # Default: +10+.
      # @return [Integer]
      attr_accessor :max_depth

      # Default maximum page size for Relay connections.
      # Used by graphql-ruby when calculating connection complexity.
      # Default: +25+.
      # @return [Integer]
      attr_accessor :default_max_page_size
    end
  end
end
