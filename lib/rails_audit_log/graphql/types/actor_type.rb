# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Types
      class ActorType < BaseObject
        graphql_name "AuditLogActor"
        description "A polymorphic reference to the actor who performed the audited action."

        field :id, GraphQL::Types::ID, null: false, description: "The actor's ID."
        field :type_name, String, null: false, description: "The actor's model class name (e.g. \"User\")."
        field :record, GraphQL::Types::JSON, null: true,
          description: "The actor record loaded from the database, serialized as JSON. Batch-loaded via dataloader."

        def id
          object[:id]
        end

        def type_name
          object[:type_name]
        end

        def record
          return nil unless object[:id] && object[:type_name]
          dataloader.with(Sources::RecordByIdSource, object[:type_name]).load(object[:id].to_s)
        end
      end
    end
  end
end
