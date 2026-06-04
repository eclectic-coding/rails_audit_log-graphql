# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Sources
      # Dataloader source that batch-loads ActiveRecord records by class name and ID,
      # returning their +attributes+ hash.
      #
      # Used internally by {Types::ActorType} and {Types::AuditedResourceType} to
      # resolve the +record+ field without N+1 queries.
      #
      # @example Manual use in a custom resolver
      #   dataloader.with(RecordByIdSource, "User").load("42")
      class RecordByIdSource < GraphQL::Dataloader::Source
        # @param class_name [String] the ActiveRecord model class name to load from
        def initialize(class_name)
          @class_name = class_name
        end

        # Batch-loads records for the given IDs.
        #
        # @param ids [Array<String>] record IDs to load
        # @return [Array<Hash, nil>] +attributes+ hash for each ID, or +nil+ when
        #   the record does not exist or the class cannot be constantized
        def fetch(ids)
          klass = @class_name.safe_constantize
          return ids.map { nil } unless klass

          records = klass.where(id: ids).index_by { |r| r.id.to_s }
          ids.map { |id| records[id]&.attributes }
        end
      end
    end
  end
end
