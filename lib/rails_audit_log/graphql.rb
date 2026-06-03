# frozen_string_literal: true

require "graphql"
require_relative "graphql/version"
require_relative "graphql/types/base_object"
require_relative "graphql/types/diff_type"
require_relative "graphql/types/actor_type"
require_relative "graphql/types/audited_resource_type"
require_relative "graphql/types/audit_log_entry_type"
require_relative "graphql/types/sort_direction_enum"
require_relative "graphql/types/audit_log_entry_sort_field_enum"
require_relative "graphql/input_objects/audit_log_entry_sort_input"
require_relative "graphql/queries/audit_log_entries_query_mixin"

module RailsAuditLog
  module Graphql
    class Error < StandardError; end
  end
end
