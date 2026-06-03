# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Types
      class ActorType < BaseObject
        graphql_name "AuditLogActor"
        description "A polymorphic reference to the actor who performed the audited action."

        field :id, GraphQL::Types::ID, null: false, description: "The actor's ID."
        field :type_name, String, null: false, description: "The actor's model class name (e.g. \"User\")."

        def id
          object[:id]
        end

        def type_name
          object[:type_name]
        end
      end
    end
  end
end
