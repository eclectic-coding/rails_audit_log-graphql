# frozen_string_literal: true

require "graphql"
require_relative "graphql/version"
require_relative "graphql/types/base_object"
require_relative "graphql/types/audit_log_entry_type"
require_relative "graphql/queries/audit_log_entries_query_mixin"

module RailsAuditLog
  module Graphql
    class Error < StandardError; end
  end
end
