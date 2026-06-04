# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Subscriptions
      module AuditLogSubscriptionsMixin
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
