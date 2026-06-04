# frozen_string_literal: true

module RailsAuditLog
  module Graphql
    module Sources
      class RecordByIdSource < GraphQL::Dataloader::Source
        def initialize(class_name)
          @class_name = class_name
        end

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
