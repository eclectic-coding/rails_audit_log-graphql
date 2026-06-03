# frozen_string_literal: true

require "rails/generators"

module RailsAuditLog
  module Generators
    module Graphql
      class InstallGenerator < Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)
        desc "Injects AuditLogEntriesQueryMixin into your GraphQL QueryType."

        QUERY_TYPE_PATH = "app/graphql/types/query_type.rb"
        MIXIN = "RailsAuditLog::Graphql::Queries::AuditLogEntriesQueryMixin"

        def inject_mixin
          if File.exist?(File.join(destination_root, QUERY_TYPE_PATH))
            inject_into_file QUERY_TYPE_PATH,
              "  include #{MIXIN}\n",
              after: /class\s+\S+\s*<\s*\S+\s*\n/
          else
            say ""
            say "#{QUERY_TYPE_PATH} not found. Add this line manually to your QueryType:", :yellow
            say "  include #{MIXIN}", :green
          end
        end

        def print_next_steps
          say ""
          say "Done! Your GraphQL API now has:", :green
          say "  auditLogEntry(id: ID!): AuditLogEntry"
          say "  auditLogEntries(...): [AuditLogEntry!]!"
          say ""
          say "See the README for full documentation."
        end
      end
    end
  end
end
