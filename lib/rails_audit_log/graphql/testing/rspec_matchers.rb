# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Testing
      # RSpec matchers for asserting GraphQL audit log entries in a query response.
      #
      # Include this module in your RSpec configuration to use the {#have_graphql_audit_entry}
      # matcher:
      #
      #   RSpec.configure do |config|
      #     config.include RailsAuditLog::Graphql::Testing::RSpecMatchers
      #   end
      #
      # Or include it in a single example group:
      #
      #   RSpec.describe "audit logging" do
      #     include RailsAuditLog::Graphql::Testing::RSpecMatchers
      #   end
      #
      # The matcher inspects the +auditLogEntries+ and +auditLogEntriesConnection.nodes+
      # keys in the response data. To use the +touching+ chain, include +diff { attribute }+
      # in your GraphQL query.
      module RSpecMatchers
        # Returns a matcher that asserts a GraphQL response contains an audit log
        # entry with the given event type.
        #
        # @param event [Symbol, String] expected event type (:create, :update, :destroy)
        # @return [HaveGraphqlAuditEntry]
        #
        # @example Assert an update entry exists
        #   result = MySchema.execute('{ auditLogEntries { event } }')
        #   expect(result).to have_graphql_audit_entry(:update)
        #
        # @example Assert an update entry that touched :title
        #   result = MySchema.execute('{ auditLogEntries { event diff { attribute } } }')
        #   expect(result).to have_graphql_audit_entry(:update).touching(:title)
        #
        # @example Assert a create entry for a specific model
        #   expect(result).to have_graphql_audit_entry(:create).for_type("Post")
        def have_graphql_audit_entry(event)
          HaveGraphqlAuditEntry.new(event.to_s)
        end

        # @api private
        class HaveGraphqlAuditEntry
          # @param event [String] the required event value
          def initialize(event)
            @event = event
            @touching = nil
            @item_type = nil
          end

          # Requires at least one matching entry's +diff+ to contain +attribute+.
          # The query must include +diff { attribute }+ for this chain to work.
          #
          # @param attribute [Symbol, String] the changed attribute name
          # @return [self]
          def touching(attribute)
            @touching = attribute.to_s
            self
          end

          # Requires all matching entries to have +itemType+ equal to +item_type+.
          #
          # @param item_type [String] the ActiveRecord model class name
          # @return [self]
          def for_type(item_type)
            @item_type = item_type.to_s
            self
          end

          # @api private
          def matches?(response)
            @response = response
            matched = extract_entries(response).select { |e| e["event"] == @event }
            matched = matched.select { |e| e["itemType"] == @item_type } if @item_type
            if @touching
              matched = matched.select { |e| e["diff"]&.any? { |d| d["attribute"] == @touching } }
            end
            matched.any?
          end

          # @api private
          def failure_message
            "expected GraphQL response to include an audit entry with event #{@event.inspect}" \
              "#{touching_clause}#{type_clause}, but it did not.\n" \
              "Entries found: #{extract_entries(@response).map { |e| e["event"] }.inspect}"
          end

          # @api private
          def failure_message_when_negated
            "expected GraphQL response not to include an audit entry with event #{@event.inspect}" \
              "#{touching_clause}#{type_clause}, but one was found."
          end

          private

          def touching_clause
            @touching ? " touching #{@touching.inspect}" : ""
          end

          def type_clause
            @item_type ? " for type #{@item_type.inspect}" : ""
          end

          def extract_entries(response)
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
end
