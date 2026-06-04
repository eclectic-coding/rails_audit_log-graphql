# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Subscriptions
      # Mixin that adds the +auditLogEntryCreated+ subscription field to a host
      # application's +SubscriptionType+.
      #
      # Include in your +SubscriptionType+:
      #
      #   class Types::SubscriptionType < Types::BaseObject
      #     include RailsAuditLog::Graphql::Subscriptions::AuditLogSubscriptionsMixin
      #   end
      #
      # The schema must also use +GraphQL::Subscriptions::ActionCableSubscriptions+:
      #
      #   class MySchema < GraphQL::Schema
      #     subscription Types::SubscriptionType
      #     use GraphQL::Subscriptions::ActionCableSubscriptions
      #   end
      #
      # @see AuditLogEntryCreated
      # @see Broadcaster
      module AuditLogSubscriptionsMixin
        # @api private
        def self.included(base)
          base.field(
            :audit_log_entry_created,
            subscription: AuditLogEntryCreated,
            description: "Fires when a new audit log entry is created."
          )
        end
      end
    end
  end
end
