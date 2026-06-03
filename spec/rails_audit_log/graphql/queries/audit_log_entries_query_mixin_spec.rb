# frozen_string_literal: true

RSpec.describe RailsAuditLog::Graphql::Queries::AuditLogEntriesQueryMixin do
  let(:query_type) do
    Class.new(GraphQL::Schema::Object) do
      graphql_name "TestQuery"
      include RailsAuditLog::Graphql::Queries::AuditLogEntriesQueryMixin
    end
  end

  let(:fields) { query_type.fields }

  describe "auditLogEntry field" do
    subject(:field) { fields.fetch("auditLogEntry") }

    it "is nullable" do
      expect(field.type.non_null?).to be false
    end

    it "returns AuditLogEntry type" do
      expect(field.type.graphql_name).to eq("AuditLogEntry")
    end

    describe "id argument" do
      subject(:arg) { field.arguments.fetch("id") }

      it "is required" do
        expect(arg.type.non_null?).to be true
      end

      it "is an ID type" do
        expect(arg.type.unwrap.graphql_name).to eq("ID")
      end
    end
  end

  describe "auditLogEntries field" do
    subject(:field) { fields.fetch("auditLogEntries") }

    it "is a non-null list of non-null entries" do
      expect(field.type.to_type_signature).to eq("[AuditLogEntry!]!")
    end

    it "exposes exactly 6 arguments" do
      expect(field.arguments.size).to eq(6)
    end

    describe "filter arguments" do
      %w[event itemType].each do |arg_name|
        it "has optional #{arg_name} String argument" do
          arg = field.arguments.fetch(arg_name)
          expect(arg.type.non_null?).to be false
          expect(arg.type.graphql_name).to eq("String")
        end
      end

      %w[itemId actorId].each do |arg_name|
        it "has optional #{arg_name} ID argument" do
          arg = field.arguments.fetch(arg_name)
          expect(arg.type.non_null?).to be false
          expect(arg.type.graphql_name).to eq("ID")
        end
      end
    end

    describe "pagination arguments" do
      it "has page argument defaulting to 1" do
        arg = field.arguments.fetch("page")
        expect(arg.type.non_null?).to be false
        expect(arg.type.graphql_name).to eq("Int")
        expect(arg.default_value).to eq(1)
      end

      it "has perPage argument defaulting to 25" do
        arg = field.arguments.fetch("perPage")
        expect(arg.type.non_null?).to be false
        expect(arg.type.graphql_name).to eq("Int")
        expect(arg.default_value).to eq(25)
      end
    end
  end
end
