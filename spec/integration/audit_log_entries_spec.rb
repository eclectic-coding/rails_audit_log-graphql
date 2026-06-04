# frozen_string_literal: true

require "rails_helper"

RSpec.describe "auditLogEntries queries" do
  let(:user) { User.create!(name: "Admin") }

  before do
    RailsAuditLog.with_actor(user) { Post.create!(title: "First post") }
    RailsAuditLog.with_actor(user) { Post.create!(title: "Second post") }
    RailsAuditLog.with_actor(user) { Post.last.update!(title: "Updated post") }
  end

  describe "auditLogEntries (offset-paginated list)" do
    it "returns all entries" do
      result = DummySchema.execute("{ auditLogEntries { id event itemType } }", context: {})
      entries = result.dig("data", "auditLogEntries")
      expect(entries.size).to eq(3)
    end

    it "filters by event" do
      result = DummySchema.execute(
        '{ auditLogEntries(event: "create") { event } }',
        context: {}
      )
      events = result.dig("data", "auditLogEntries").map { |e| e["event"] }
      expect(events).to all(eq("create"))
    end

    it "filters by itemType" do
      result = DummySchema.execute(
        '{ auditLogEntries(itemType: "Post") { itemType } }',
        context: {}
      )
      types = result.dig("data", "auditLogEntries").map { |e| e["itemType"] }
      expect(types).to all(eq("Post"))
    end

    it "paginates with page and perPage" do
      result = DummySchema.execute(
        "{ auditLogEntries(page: 1, perPage: 2) { id } }",
        context: {}
      )
      expect(result.dig("data", "auditLogEntries").size).to eq(2)
    end

    it "orders by created_at DESC" do
      result = DummySchema.execute("{ auditLogEntries { event } }", context: {})
      entries = result.dig("data", "auditLogEntries")
      expect(entries.first["event"]).to eq("update")
    end

    it "filters by since" do
      future = (Time.now + 60).iso8601
      result = DummySchema.execute(
        "{ auditLogEntries(since: \"#{future}\") { id } }",
        context: {}
      )
      expect(result.dig("data", "auditLogEntries")).to be_empty
    end

    it "filters by until" do
      past = (Time.now - 60).iso8601
      result = DummySchema.execute(
        "{ auditLogEntries(until: \"#{past}\") { id } }",
        context: {}
      )
      expect(result.dig("data", "auditLogEntries")).to be_empty
    end

    it "filters by touching" do
      result = DummySchema.execute(
        '{ auditLogEntries(touching: "title") { event } }',
        context: {}
      )
      entries = result.dig("data", "auditLogEntries")
      expect(entries).not_to be_empty
      expect(entries.map { |e| e["event"] }).to all(satisfy { |ev| %w[create update].include?(ev) })
    end

    it "returns no entries when touching an attribute that was never changed" do
      result = DummySchema.execute(
        '{ auditLogEntries(touching: "nonexistent_attribute") { id } }',
        context: {}
      )
      expect(result.dig("data", "auditLogEntries")).to be_empty
    end

    it "sorts ASC with orderBy" do
      result = DummySchema.execute(
        "{ auditLogEntries(orderBy: { field: CREATED_AT, direction: ASC }) { event } }",
        context: {}
      )
      entries = result.dig("data", "auditLogEntries")
      expect(entries.first["event"]).to eq("create")
    end

    it "returns entries within a time range" do
      before_time = (Time.now - 5).iso8601
      after_time = (Time.now + 5).iso8601
      result = DummySchema.execute(
        "{ auditLogEntries(since: \"#{before_time}\", until: \"#{after_time}\") { id } }",
        context: {}
      )
      expect(result.dig("data", "auditLogEntries").size).to eq(3)
    end
  end

  describe "auditLogEntriesConnection (cursor-paginated)" do
    it "returns all entries via nodes" do
      result = DummySchema.execute("{ auditLogEntriesConnection { nodes { id event itemType } } }", context: {})
      entries = result.dig("data", "auditLogEntriesConnection", "nodes")
      expect(entries.size).to eq(3)
    end

    it "filters by event" do
      result = DummySchema.execute(
        '{ auditLogEntriesConnection(event: "create") { nodes { event } } }',
        context: {}
      )
      events = result.dig("data", "auditLogEntriesConnection", "nodes").map { |e| e["event"] }
      expect(events).to all(eq("create"))
    end

    it "paginates forward with first" do
      result = DummySchema.execute(
        "{ auditLogEntriesConnection(first: 2) { nodes { id } pageInfo { hasNextPage endCursor } } }",
        context: {}
      )
      nodes = result.dig("data", "auditLogEntriesConnection", "nodes")
      page_info = result.dig("data", "auditLogEntriesConnection", "pageInfo")
      expect(nodes.size).to eq(2)
      expect(page_info["hasNextPage"]).to be true
    end

    it "paginates to the next page with after cursor" do
      first_page = DummySchema.execute(
        "{ auditLogEntriesConnection(first: 2) { nodes { id } pageInfo { endCursor } } }",
        context: {}
      )
      cursor = first_page.dig("data", "auditLogEntriesConnection", "pageInfo", "endCursor")

      second_page = DummySchema.execute(
        "{ auditLogEntriesConnection(first: 2, after: \"#{cursor}\") { nodes { id } pageInfo { hasNextPage } } }",
        context: {}
      )
      nodes = second_page.dig("data", "auditLogEntriesConnection", "nodes")
      expect(nodes.size).to eq(1)
      expect(second_page.dig("data", "auditLogEntriesConnection", "pageInfo", "hasNextPage")).to be false
    end

    it "orders by created_at DESC" do
      result = DummySchema.execute("{ auditLogEntriesConnection { nodes { event } } }", context: {})
      entries = result.dig("data", "auditLogEntriesConnection", "nodes")
      expect(entries.first["event"]).to eq("update")
    end

    it "sorts ASC with orderBy" do
      result = DummySchema.execute(
        "{ auditLogEntriesConnection(orderBy: { field: CREATED_AT, direction: ASC }) { nodes { event } } }",
        context: {}
      )
      entries = result.dig("data", "auditLogEntriesConnection", "nodes")
      expect(entries.first["event"]).to eq("create")
    end
  end

  describe "auditLogEntry" do
    it "returns a single entry by id" do
      entry_id = RailsAuditLog::AuditLogEntry.first.id.to_s
      result = DummySchema.execute(
        "{ auditLogEntry(id: \"#{entry_id}\") { id event } }",
        context: {}
      )
      expect(result.dig("data", "auditLogEntry", "id")).to eq(entry_id)
    end

    it "returns nil for an unknown id" do
      result = DummySchema.execute(
        '{ auditLogEntry(id: "999999") { id } }',
        context: {}
      )
      expect(result.dig("data", "auditLogEntry")).to be_nil
    end
  end

  describe "actor field" do
    it "returns actor id and typeName when an actor is present" do
      result = DummySchema.execute(
        '{ auditLogEntries(event: "create") { actor { id typeName } } }',
        context: {}
      )
      entry = result.dig("data", "auditLogEntries").first
      expect(entry["actor"]["id"]).to eq(user.id.to_s)
      expect(entry["actor"]["typeName"]).to eq("User")
    end

    it "returns nil for entries with no actor" do
      RailsAuditLog::AuditLogEntry.create!(
        event: "create", item_type: "Post", item_id: 999
      )
      result = DummySchema.execute(
        "{ auditLogEntries { actor { id typeName } } }",
        context: {}
      )
      no_actor = result.dig("data", "auditLogEntries").find { |e| e["actor"].nil? }
      expect(no_actor).not_to be_nil
    end
  end

  describe "auditedResource field" do
    it "returns the item type and id" do
      result = DummySchema.execute(
        "{ auditLogEntries { auditedResource { id typeName } } }",
        context: {}
      )
      resources = result.dig("data", "auditLogEntries").map { |e| e["auditedResource"] }
      expect(resources).to all(include("typeName" => "Post"))
      expect(resources.map { |r| r["id"] }).to all(be_present)
    end
  end

  describe "diff field" do
    it "returns structured diffs for an update entry" do
      result = DummySchema.execute(
        '{ auditLogEntries(event: "update") { diff { attribute from to } } }',
        context: {}
      )
      diffs = result.dig("data", "auditLogEntries").first["diff"]
      title_diff = diffs.find { |d| d["attribute"] == "title" }
      expect(title_diff["from"]).to eq("Second post")
      expect(title_diff["to"]).to eq("Updated post")
    end

    it "returns nil diff for entries with no object_changes" do
      RailsAuditLog::AuditLogEntry.create!(
        event: "destroy", item_type: "Post", item_id: 1
      )
      result = DummySchema.execute(
        '{ auditLogEntries(event: "destroy") { diff { attribute } } }',
        context: {}
      )
      entry = result.dig("data", "auditLogEntries").first
      expect(entry["diff"]).to be_nil
    end
  end

  describe "authentication" do
    around do |example|
      RailsAuditLog.authenticate { |ctx| ctx[:current_user] }
      example.run
      RailsAuditLog.instance_variable_set(:@authenticate, nil)
    end

    it "raises Unauthorized on auditLogEntries when block returns falsy" do
      result = DummySchema.execute(
        "{ auditLogEntries { id } }",
        context: {current_user: nil}
      )
      expect(result["errors"].first["message"]).to eq("Unauthorized")
    end

    it "raises Unauthorized on auditLogEntriesConnection when block returns falsy" do
      result = DummySchema.execute(
        "{ auditLogEntriesConnection { nodes { id } } }",
        context: {current_user: nil}
      )
      expect(result["errors"].first["message"]).to eq("Unauthorized")
    end

    it "permits access when block returns truthy" do
      result = DummySchema.execute(
        "{ auditLogEntries { id } }",
        context: {current_user: user}
      )
      expect(result["errors"]).to be_nil
    end
  end

  describe "auditLogEntriesCount aggregation" do
    it "returns the total count" do
      result = DummySchema.execute("{ auditLogEntriesCount }", context: {})
      expect(result.dig("data", "auditLogEntriesCount")).to eq(3)
    end

    it "filters by event" do
      result = DummySchema.execute('{ auditLogEntriesCount(event: "create") }', context: {})
      expect(result.dig("data", "auditLogEntriesCount")).to eq(2)
    end

    it "filters by itemType" do
      result = DummySchema.execute('{ auditLogEntriesCount(itemType: "Post") }', context: {})
      expect(result.dig("data", "auditLogEntriesCount")).to eq(3)
    end

    it "filters by since" do
      future = (Time.now + 60).iso8601
      result = DummySchema.execute(
        "{ auditLogEntriesCount(since: \"#{future}\") }",
        context: {}
      )
      expect(result.dig("data", "auditLogEntriesCount")).to eq(0)
    end
  end

  describe "forTenant filtering" do
    before do
      RailsAuditLog.with_actor(user) do
        post = Post.last
        post.instance_variable_set(:@_audit_tenant, "acme")
        RailsAuditLog::AuditLogEntry.create!(
          event: "update",
          item_type: "Post",
          item_id: post.id,
          tenant_id: "acme"
        )
      end
    end

    it "filters auditLogEntries by forTenant" do
      result = DummySchema.execute(
        '{ auditLogEntries(forTenant: "acme") { id } }',
        context: {}
      )
      expect(result.dig("data", "auditLogEntries").size).to eq(1)
    end

    it "filters auditLogEntriesConnection by forTenant" do
      result = DummySchema.execute(
        '{ auditLogEntriesConnection(forTenant: "acme") { nodes { id } } }',
        context: {}
      )
      expect(result.dig("data", "auditLogEntriesConnection", "nodes").size).to eq(1)
    end

    it "applies auto-tenant via RailsAuditLog.current_tenant" do
      allow(RailsAuditLog).to receive(:current_tenant).and_return(-> { "acme" })
      result = DummySchema.execute("{ auditLogEntriesCount }", context: {})
      expect(result.dig("data", "auditLogEntriesCount")).to eq(1)
    end
  end
end
