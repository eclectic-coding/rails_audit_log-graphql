# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Types
      class AuditedResourceType < BaseObject
        graphql_name "AuditedResource"
        description "A reference to the model record that was changed."

        field :id, GraphQL::Types::ID, null: false, description: "The audited record's ID."
        field :type_name, String, null: false, description: "The audited model class name (e.g. \"Post\")."

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
