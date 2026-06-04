# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Types
      class AuditedResourceType < BaseObject
        graphql_name "AuditedResource"
        description "A reference to the model record that was changed."

        field :id, GraphQL::Types::ID, null: false, description: "The audited record's ID."
        field :type_name, String, null: false, description: "The audited model class name (e.g. \"Post\")."
        field :record, GraphQL::Types::JSON, null: true,
          description: "The audited record loaded from the database, serialized as JSON. Batch-loaded via dataloader."

        def id
          object[:id]
        end

        def type_name
          object[:type_name]
        end

        def record
          dataloader.with(Sources::RecordByIdSource, object[:type_name]).load(object[:id].to_s)
        end
      end
    end
  end
end
