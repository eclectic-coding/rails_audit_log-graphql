# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Types
      class SortDirectionEnum < GraphQL::Schema::Enum
        graphql_name "SortDirection"
        description "Sort direction for ordered queries."

        value "ASC", value: :asc, description: "Ascending order."
        value "DESC", value: :desc, description: "Descending order."
      end
    end
  end
end
