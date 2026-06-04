# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module SchemaPlugin
      def self.included(base)
        base.max_complexity(RailsAuditLog::Graphql.max_complexity)
        base.max_depth(RailsAuditLog::Graphql.max_depth)
        base.default_max_page_size(RailsAuditLog::Graphql.default_max_page_size)
        base.use(GraphQL::Dataloader)
      end
    end
  end
end
