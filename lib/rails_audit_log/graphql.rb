# frozen_string_literal: true

require "graphql"
require_relative "graphql/version"
require_relative "graphql/types/base_object"
require_relative "graphql/types/audit_log_entry_type"

module RailsAuditLog
  module Graphql
    class Error < StandardError; end
  end
end
