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

module RailsAuditLog
  module Graphql
    class Error < StandardError; end

    @max_complexity = 200
    @max_depth = 10
    @default_max_page_size = 25

    class << self
      attr_accessor :max_complexity, :max_depth, :default_max_page_size
    end
  end
end
