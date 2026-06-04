# frozen_string_literal: true

require "rails_helper"
require "rails_audit_log/graphql/testing"

RSpec.describe RailsAuditLog::Graphql::Testing::RSpecMatchers do
  include described_class

  let(:response_with_entries) do
    {
      "data" => {
        "auditLogEntries" => [
          {"event" => "create", "itemType" => "Post", "diff" => nil},
          {"event" => "update", "itemType" => "Post", "diff" => [{"attribute" => "title", "from" => "old", "to" => "new"}]},
          {"event" => "destroy", "itemType" => "Post", "diff" => nil}
        ]
      }
    }
  end

  let(:response_with_connection) do
    {
      "data" => {
        "auditLogEntriesConnection" => {
          "nodes" => [
            {"event" => "create", "itemType" => "Comment", "diff" => nil}
          ]
        }
      }
    }
  end

  let(:empty_response) { {"data" => {"auditLogEntries" => []}} }

  describe "#have_graphql_audit_entry" do
    it "matches by event in auditLogEntries" do
      expect(response_with_entries).to have_graphql_audit_entry(:update)
    end

    it "matches by event in auditLogEntriesConnection nodes" do
      expect(response_with_connection).to have_graphql_audit_entry(:create)
    end

    it "does not match when event is absent" do
      expect(response_with_entries).not_to have_graphql_audit_entry(:deploy)
    end

    it "does not match against an empty entries list" do
      expect(empty_response).not_to have_graphql_audit_entry(:create)
    end

    it "accepts a string event" do
      expect(response_with_entries).to have_graphql_audit_entry("create")
    end
  end

  describe "#touching" do
    it "matches when diff includes the attribute" do
      expect(response_with_entries).to have_graphql_audit_entry(:update).touching(:title)
    end

    it "does not match when diff does not include the attribute" do
      expect(response_with_entries).not_to have_graphql_audit_entry(:update).touching(:body)
    end

    it "does not match when diff is nil" do
      expect(response_with_entries).not_to have_graphql_audit_entry(:create).touching(:title)
    end

    it "accepts a string attribute" do
      expect(response_with_entries).to have_graphql_audit_entry(:update).touching("title")
    end
  end

  describe "#for_type" do
    it "matches when itemType equals the given type" do
      expect(response_with_entries).to have_graphql_audit_entry(:create).for_type("Post")
    end

    it "does not match when itemType differs" do
      expect(response_with_entries).not_to have_graphql_audit_entry(:create).for_type("Comment")
    end
  end

  describe "failure messages" do
    subject(:matcher) { have_graphql_audit_entry(:destroy).touching(:title) }

    before { matcher.matches?(response_with_entries) }

    it "includes the event and attribute in the failure message" do
      expect(matcher.failure_message).to include('"destroy"', '"title"')
    end

    it "lists the events found in the failure message" do
      expect(matcher.failure_message).to include("create", "update", "destroy")
    end

    it "includes the event in the negated failure message" do
      expect(matcher.failure_message_when_negated).to include('"destroy"')
    end
  end

  describe "with a real GraphQL response" do
    let(:user) { User.create!(name: "Admin") }

    before do
      RailsAuditLog.with_actor(user) { Post.create!(title: "Hello") }
      RailsAuditLog.with_actor(user) { Post.last.update!(title: "World") }
    end

    it "matches a real create response" do
      result = DummySchema.execute(
        '{ auditLogEntries(event: "create") { event itemType diff { attribute } } }',
        context: {}
      )
      expect(result).to have_graphql_audit_entry(:create).for_type("Post")
    end

    it "matches a real update response with touching" do
      result = DummySchema.execute(
        '{ auditLogEntries(event: "update") { event itemType diff { attribute from to } } }',
        context: {}
      )
      expect(result).to have_graphql_audit_entry(:update).touching(:title)
    end

    it "does not match when the event is absent from the response" do
      result = DummySchema.execute(
        '{ auditLogEntries(event: "create") { event } }',
        context: {}
      )
      expect(result).not_to have_graphql_audit_entry(:update)
    end
  end
end
