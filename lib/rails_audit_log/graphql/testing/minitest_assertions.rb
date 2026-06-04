# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Testing
      # Minitest assertions for GraphQL audit log entries.
      #
      # Include this module in a test class or in a shared support file:
      #
      #   class ActiveSupport::TestCase
      #     include RailsAuditLog::Graphql::Testing::MinitestAssertions
      #   end
      #
      # The assertions inspect the +auditLogEntries+ and +auditLogEntriesConnection.nodes+
      # keys in the response data. To use the +touching:+ option, include +diff { attribute }+
      # in your GraphQL query.
      module MinitestAssertions
        # Asserts that the GraphQL response contains at least one audit log entry
        # matching the given criteria.
        #
        # @param response [Hash, GraphQL::Query::Result] the result of +Schema.execute+
        # @param event [Symbol, String] expected event type (:create, :update, :destroy)
        # @param touching [Symbol, String, nil] when given, requires the entry's +diff+ to
        #   include an attribute with this name (query must include +diff { attribute }+)
        # @param item_type [String, nil] when given, requires the entry's +itemType+ to match
        # @param message [String, nil] custom failure message
        #
        # @example Assert an update entry exists
        #   result = MySchema.execute('{ auditLogEntries { event } }')
        #   assert_graphql_audit_entry result, event: :update
        #
        # @example Assert an update entry that touched :title
        #   result = MySchema.execute('{ auditLogEntries { event diff { attribute } } }')
        #   assert_graphql_audit_entry result, event: :update, touching: :title
        def assert_graphql_audit_entry(response, event:, touching: nil, item_type: nil, message: nil)
          matched = filter_entries(response, event: event, touching: touching, item_type: item_type)
          default_msg = build_message("Expected", event, touching, item_type)
          assert matched.any?, message || default_msg
        end

        # Asserts that the GraphQL response does NOT contain an audit log entry
        # matching the given criteria.
        #
        # @param response [Hash, GraphQL::Query::Result] the result of +Schema.execute+
        # @param event [Symbol, String] the event type to check
        # @param touching [Symbol, String, nil] attribute name to match against +diff+
        # @param item_type [String, nil] model class name to match against +itemType+
        # @param message [String, nil] custom failure message
        def refute_graphql_audit_entry(response, event:, touching: nil, item_type: nil, message: nil)
          matched = filter_entries(response, event: event, touching: touching, item_type: item_type)
          default_msg = build_message("Expected no", event, touching, item_type)
          refute matched.any?, message || default_msg
        end

        private

        def filter_entries(response, event:, touching:, item_type:)
          entries = extract_graphql_entries(response)
          matched = entries.select { |e| e["event"] == event.to_s }
          matched = matched.select { |e| e["itemType"] == item_type.to_s } if item_type
          if touching
            matched = matched.select { |e| e["diff"]&.any? { |d| d["attribute"] == touching.to_s } }
          end
          matched
        end

        def build_message(prefix, event, touching, item_type)
          msg = "#{prefix} GraphQL audit entry with event #{event.inspect}"
          msg += " touching #{touching.inspect}" if touching
          msg += " for type #{item_type.inspect}" if item_type
          msg
        end

        def extract_graphql_entries(response)
          data = response.respond_to?(:[]) ? (response["data"] || response[:data]) : nil
          return [] unless data

          entries = []
          entries += Array(data["auditLogEntries"])
          entries += Array(data.dig("auditLogEntriesConnection", "nodes"))
          entries += Array(data.dig("auditLogEntriesConnection", "edges")).filter_map { |e| e["node"] }
          entries
        end
      end
    end
  end
end
