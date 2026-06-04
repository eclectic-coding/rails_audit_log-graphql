# frozen_string_literal: true

require "rails/generators"

module RailsAuditLog
  module Generators
    module Graphql
      class InstallGenerator < Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)
        desc "Injects AuditLogEntriesQueryMixin into your GraphQL QueryType and SchemaPlugin into your schema."

        QUERY_TYPE_PATH = "app/graphql/types/query_type.rb"
        MIXIN = "RailsAuditLog::Graphql::Queries::AuditLogEntriesQueryMixin"
        SCHEMA_PLUGIN = "RailsAuditLog::Graphql::SchemaPlugin"

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

        def inject_schema_plugin
          schema_files = Dir.glob(File.join(destination_root, "app/graphql/**/*schema*.rb"))
          if schema_files.any?
            schema_path = schema_files.first.delete_prefix("#{destination_root}/")
            inject_into_file schema_path,
              "  include #{SCHEMA_PLUGIN}\n",
              after: /class\s+\S+\s*<\s*GraphQL::Schema\s*\n/
          else
            say ""
            say "No schema file found. Add this line manually to your GraphQL::Schema subclass:", :yellow
            say "  include #{SCHEMA_PLUGIN}", :green
          end
        end

        def print_next_steps
          say ""
          say "Done! Your GraphQL API now has:", :green
          say "  auditLogEntry(id: ID!): AuditLogEntry"
          say "  auditLogEntries(...): [AuditLogEntry!]!"
          say "  auditLogReify(itemType:, itemId:, at:): AuditLogJson"
          say "  auditLogEntriesCount(...): Int!"
          say ""
          say "SchemaPlugin applies complexity/depth limits and enables dataloader."
          say "Override defaults in an initializer:"
          say "  RailsAuditLog::Graphql.max_complexity = 500"
          say ""
          say "See the README for full documentation."
        end
      end
    end
  end
end
