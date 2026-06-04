# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Subscriptions
      class Broadcaster
        EVENT = "rails_audit_log.entry_created"

        def initialize(schema:)
          @schema = schema
          @subscriber = nil
        end

        def start
          @subscriber = ActiveSupport::Notifications.subscribe(EVENT) do |*, payload|
            broadcast(payload[:entry])
          end
        end

        def stop
          ActiveSupport::Notifications.unsubscribe(@subscriber) if @subscriber
          @subscriber = nil
        end

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
