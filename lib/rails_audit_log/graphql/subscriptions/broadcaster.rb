# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Subscriptions
      # Bridges +ActiveSupport::Notifications+ events emitted by
      # +rails_audit_log+ to GraphQL subscription triggers.
      #
      # Start it once in an initializer after the schema is defined:
      #
      #   Rails.application.config.after_initialize do
      #     RailsAuditLog::Graphql::Subscriptions::Broadcaster.new(schema: MySchema).start
      #   end
      #
      # For each +rails_audit_log.entry_created+ notification the broadcaster
      # fires two subscription triggers:
      # - +auditLogEntryCreated(itemType:, itemId:)+ for record-specific subscribers
      # - +auditLogEntryCreated(actorId:)+ for actor-specific subscribers (when an
      #   actor is present on the entry)
      class Broadcaster
        # @api private
        EVENT = "rails_audit_log.entry_created"

        # @param schema [Class] the GraphQL schema class (must use
        #   +GraphQL::Subscriptions::ActionCableSubscriptions+)
        def initialize(schema:)
          @schema = schema
          @subscriber = nil
        end

        # Subscribe to +rails_audit_log.entry_created+ notifications and begin
        # broadcasting to GraphQL subscribers. Idempotent — calling +start+ a
        # second time replaces the previous subscriber.
        #
        # @return [void]
        def start
          @subscriber = ActiveSupport::Notifications.subscribe(EVENT) do |*, payload|
            broadcast(payload[:entry])
          end
        end

        # Unsubscribe from +ActiveSupport::Notifications+. After calling +stop+,
        # no further subscription triggers will fire until {#start} is called again.
        #
        # @return [void]
        def stop
          ActiveSupport::Notifications.unsubscribe(@subscriber) if @subscriber
          @subscriber = nil
        end

        # Trigger GraphQL subscriptions for +entry+. Fires both the
        # record-scoped and actor-scoped variants.
        #
        # @param entry [RailsAuditLog::AuditLogEntry] the newly created entry
        # @return [void]
        def broadcast(entry)
          @schema.subscriptions.trigger(
            "audit_log_entry_created",
            {item_type: entry.item_type, item_id: entry.item_id.to_s},
            entry
          )

          return unless entry.actor_id.present?

          @schema.subscriptions.trigger(
            "audit_log_entry_created",
            {actor_id: entry.actor_id.to_s},
            entry
          )
        end
      end
    end
  end
end
