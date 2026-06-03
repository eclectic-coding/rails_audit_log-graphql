# frozen_string_literal: true

require "rails_helper"

RSpec.describe "auditLogEntries queries" do
  let(:user) { User.create!(name: "Admin") }

  before do
    RailsAuditLog.with_actor(user) { Post.create!(title: "First post") }
    RailsAuditLog.with_actor(user) { Post.create!(title: "Second post") }
    RailsAuditLog.with_actor(user) { Post.last.update!(title: "Updated post") }
  end

  describe "auditLogEntries" do
    it "returns all entries" do
      result = DummySchema.execute("{ auditLogEntries { nodes { id event itemType } } }", context: {})
      entries = result.dig("data", "auditLogEntries", "nodes")
      expect(entries.size).to eq(3)
    end

    it "filters by event" do
      result = DummySchema.execute(
        '{ auditLogEntries(event: "create") { nodes { event } } }',
        context: {}
      )
      events = result.dig("data", "auditLogEntries", "nodes").map { |e| e["event"] }
      expect(events).to all(eq("create"))
    end

    it "filters by itemType" do
      result = DummySchema.execute(
        '{ auditLogEntries(itemType: "Post") { nodes { itemType } } }',
        context: {}
      )
      types = result.dig("data", "auditLogEntries", "nodes").map { |e| e["itemType"] }
      expect(types).to all(eq("Post"))
    end

    it "paginates forward with first" do
      result = DummySchema.execute(
        "{ auditLogEntries(first: 2) { nodes { id } pageInfo { hasNextPage endCursor } } }",
        context: {}
      )
      nodes = result.dig("data", "auditLogEntries", "nodes")
      page_info = result.dig("data", "auditLogEntries", "pageInfo")
      expect(nodes.size).to eq(2)
      expect(page_info["hasNextPage"]).to be true
    end

    it "paginates to the next page with after cursor" do
      first_page = DummySchema.execute(
        "{ auditLogEntries(first: 2) { nodes { id } pageInfo { endCursor } } }",
        context: {}
      )
      cursor = first_page.dig("data", "auditLogEntries", "pageInfo", "endCursor")

      second_page = DummySchema.execute(
        "{ auditLogEntries(first: 2, after: \"#{cursor}\") { nodes { id } pageInfo { hasNextPage } } }",
        context: {}
      )
      nodes = second_page.dig("data", "auditLogEntries", "nodes")
      expect(nodes.size).to eq(1)
      expect(second_page.dig("data", "auditLogEntries", "pageInfo", "hasNextPage")).to be false
    end

    it "orders by created_at DESC" do
      result = DummySchema.execute("{ auditLogEntries { nodes { event } } }", context: {})
      entries = result.dig("data", "auditLogEntries", "nodes")
      expect(entries.first["event"]).to eq("update")
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

  describe "authentication" do
    around do |example|
      RailsAuditLog.authenticate { |ctx| ctx[:current_user] }
      example.run
      RailsAuditLog.instance_variable_set(:@authenticate, nil)
    end

    it "raises Unauthorized when block returns falsy" do
      result = DummySchema.execute(
        "{ auditLogEntries { nodes { id } } }",
        context: {current_user: nil}
      )
      expect(result["errors"].first["message"]).to eq("Unauthorized")
    end

    it "permits access when block returns truthy" do
      result = DummySchema.execute(
        "{ auditLogEntries { nodes { id } } }",
        context: {current_user: user}
      )
      expect(result["errors"]).to be_nil
    end
  end
end
