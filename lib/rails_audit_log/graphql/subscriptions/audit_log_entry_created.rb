# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Subscriptions
      class AuditLogEntryCreated < Types::BaseSubscription
        description "Fires when a new audit log entry is created."

        argument :item_type, String, required: false,
          description: "Filter to entries for a specific model class name."
        argument :item_id, GraphQL::Types::ID, required: false,
          description: "Filter to entries for a specific record ID."
        argument :actor_id, GraphQL::Types::ID, required: false,
          description: "Filter to entries by a specific actor ID."

        type Types::AuditLogEntryType, null: false
      end
    end
  end
end
