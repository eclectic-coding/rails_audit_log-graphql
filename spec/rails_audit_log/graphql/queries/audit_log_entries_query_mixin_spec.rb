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

  describe "auditLogEntriesConnection field" do
    subject(:field) { fields.fetch("auditLogEntriesConnection") }

    it "returns a non-null connection type" do
      expect(field.type.to_type_signature).to eq("AuditLogEntryConnection!")
    end

    it "exposes exactly 8 arguments (4 filters + 4 cursor pagination)" do
      expect(field.arguments.size).to eq(8)
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

    describe "cursor pagination arguments" do
      %w[first last].each do |arg_name|
        it "has optional #{arg_name} Int argument" do
          arg = field.arguments.fetch(arg_name)
          expect(arg.type.non_null?).to be false
          expect(arg.type.graphql_name).to eq("Int")
        end
      end

      %w[after before].each do |arg_name|
        it "has optional #{arg_name} String argument" do
          arg = field.arguments.fetch(arg_name)
          expect(arg.type.non_null?).to be false
          expect(arg.type.graphql_name).to eq("String")
        end
      end
    end
  end

  describe "resolver methods" do
    let(:graphql_context) { {} }

    let(:resolver) do
      ctx = graphql_context
      Object.new.tap do |o|
        o.extend(described_class)
        o.define_singleton_method(:context) { ctx }
      end
    end

    let(:scope) { double("scope") }

    before do
      stub_const("RailsAuditLog::AuditLogEntry", Class.new)
      allow(RailsAuditLog).to receive(:authenticate).and_return(nil)
      allow(RailsAuditLog::AuditLogEntry).to receive(:order).with(created_at: :desc).and_return(scope)
      allow(scope).to receive(:where).and_return(scope)
      allow(scope).to receive(:limit).and_return(scope)
      allow(scope).to receive(:offset).and_return(scope)
    end

    describe "#resolve_audit_log_entry" do
      it "finds entry by id" do
        entry = double("entry")
        allow(RailsAuditLog::AuditLogEntry).to receive(:find_by).with(id: "1").and_return(entry)
        expect(resolver.resolve_audit_log_entry(id: "1")).to eq(entry)
      end

      it "returns nil when not found" do
        allow(RailsAuditLog::AuditLogEntry).to receive(:find_by).and_return(nil)
        expect(resolver.resolve_audit_log_entry(id: "999")).to be_nil
      end
    end

    describe "#resolve_audit_log_entries" do
      it "applies default pagination (page 1, per_page 25)" do
        expect(scope).to receive(:limit).with(25).and_return(scope)
        expect(scope).to receive(:offset).with(0).and_return(scope)
        resolver.resolve_audit_log_entries
      end

      it "filters by event" do
        expect(scope).to receive(:where).with(event: "create").and_return(scope)
        resolver.resolve_audit_log_entries(event: "create")
      end

      it "filters by item_type" do
        expect(scope).to receive(:where).with(item_type: "Article").and_return(scope)
        resolver.resolve_audit_log_entries(item_type: "Article")
      end

      it "filters by item_id" do
        expect(scope).to receive(:where).with(item_id: "42").and_return(scope)
        resolver.resolve_audit_log_entries(item_id: "42")
      end

      it "filters by actor_id" do
        expect(scope).to receive(:where).with(actor_id: "7").and_return(scope)
        resolver.resolve_audit_log_entries(actor_id: "7")
      end

      it "calculates offset correctly for page 2" do
        expect(scope).to receive(:limit).with(10).and_return(scope)
        expect(scope).to receive(:offset).with(10).and_return(scope)
        resolver.resolve_audit_log_entries(page: 2, per_page: 10)
      end
    end

    describe "#resolve_audit_log_entries_connection" do
      it "returns the ordered scope when no filters given" do
        expect(resolver.resolve_audit_log_entries_connection).to eq(scope)
      end

      it "filters by event" do
        expect(scope).to receive(:where).with(event: "create").and_return(scope)
        resolver.resolve_audit_log_entries_connection(event: "create")
      end

      it "filters by item_type" do
        expect(scope).to receive(:where).with(item_type: "Article").and_return(scope)
        resolver.resolve_audit_log_entries_connection(item_type: "Article")
      end

      it "filters by item_id" do
        expect(scope).to receive(:where).with(item_id: "42").and_return(scope)
        resolver.resolve_audit_log_entries_connection(item_id: "42")
      end

      it "filters by actor_id" do
        expect(scope).to receive(:where).with(actor_id: "7").and_return(scope)
        resolver.resolve_audit_log_entries_connection(actor_id: "7")
      end
    end

    describe "authentication" do
      before do
        allow(RailsAuditLog::AuditLogEntry).to receive(:find_by).and_return(nil)
      end

      context "when no authenticate block is configured" do
        before { allow(RailsAuditLog).to receive(:authenticate).and_return(nil) }

        it "allows auditLogEntry through" do
          expect { resolver.resolve_audit_log_entry(id: "1") }.not_to raise_error
        end

        it "allows auditLogEntries through" do
          expect { resolver.resolve_audit_log_entries }.not_to raise_error
        end

        it "allows auditLogEntriesConnection through" do
          expect { resolver.resolve_audit_log_entries_connection }.not_to raise_error
        end
      end

      context "when authenticate block returns truthy" do
        before { allow(RailsAuditLog).to receive(:authenticate).and_return(->(ctx) { true }) }

        it "allows auditLogEntry through" do
          expect { resolver.resolve_audit_log_entry(id: "1") }.not_to raise_error
        end

        it "allows auditLogEntries through" do
          expect { resolver.resolve_audit_log_entries }.not_to raise_error
        end

        it "allows auditLogEntriesConnection through" do
          expect { resolver.resolve_audit_log_entries_connection }.not_to raise_error
        end
      end

      context "when authenticate block returns falsy" do
        before { allow(RailsAuditLog).to receive(:authenticate).and_return(->(ctx) { false }) }

        it "raises GraphQL::ExecutionError for auditLogEntry" do
          expect { resolver.resolve_audit_log_entry(id: "1") }
            .to raise_error(GraphQL::ExecutionError, "Unauthorized")
        end

        it "raises GraphQL::ExecutionError for auditLogEntries" do
          expect { resolver.resolve_audit_log_entries }
            .to raise_error(GraphQL::ExecutionError, "Unauthorized")
        end

        it "raises GraphQL::ExecutionError for auditLogEntriesConnection" do
          expect { resolver.resolve_audit_log_entries_connection }
            .to raise_error(GraphQL::ExecutionError, "Unauthorized")
        end
      end

      it "passes the graphql context to the authenticate block" do
        graphql_context[:current_user] = "admin"
        received_ctx = nil
        allow(RailsAuditLog).to receive(:authenticate).and_return(->(ctx) {
          received_ctx = ctx
          true
        })
        resolver.resolve_audit_log_entry(id: "1")
        expect(received_ctx[:current_user]).to eq("admin")
      end
    end
  end
end
