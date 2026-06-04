# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    # Schema-level plugin that applies query-protection limits and enables
    # dataloader batching in one +include+.
    #
    # Include in your GraphQL schema class:
    #
    #   class MySchema < GraphQL::Schema
    #     include RailsAuditLog::Graphql::SchemaPlugin
    #     query Types::QueryType
    #   end
    #
    # This applies the following defaults (all overridable via
    # {RailsAuditLog::Graphql} class-level accessors):
    #
    # | Setting                | Default | Description                                      |
    # |------------------------|---------|--------------------------------------------------|
    # | +max_complexity+       | 200     | Reject queries whose complexity exceeds this     |
    # | +max_depth+            | 10      | Reject queries nested deeper than this           |
    # | +default_max_page_size+| 25      | Page-size assumption for connection complexity   |
    #
    # Also enables +GraphQL::Dataloader+ for N+1-free batch loading of
    # +actor.record+ and +auditedResource.record+ fields.
    module SchemaPlugin
      # @api private
      def self.included(base)
        base.max_complexity(RailsAuditLog::Graphql.max_complexity)
        base.max_depth(RailsAuditLog::Graphql.max_depth)
        base.default_max_page_size(RailsAuditLog::Graphql.default_max_page_size)
        base.use(GraphQL::Dataloader)
      end
    end
  end
end
