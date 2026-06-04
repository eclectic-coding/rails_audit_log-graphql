# frozen_string_literal: true

require "rails_helper"
require "rails_audit_log/graphql/testing"

RSpec.describe RailsAuditLog::Graphql::Testing::MinitestAssertions do
  # Wrap in a lightweight Minitest-like double so we can test the assertions
  # without pulling in the full Minitest stack.
  let(:test_obj) do
    obj = Object.new
    obj.extend(described_class)

    def obj.assert(condition, message = nil)
      raise message || "Assertion failed" unless condition
    end

    def obj.refute(condition, message = nil)
      raise message || "Refutation failed" if condition
    end

    obj
  end

  let(:response_with_entries) do
    {
      "data" => {
        "auditLogEntries" => [
          {"event" => "create", "itemType" => "Post", "diff" => nil},
          {"event" => "update", "itemType" => "Post", "diff" => [{"attribute" => "title", "from" => "old", "to" => "new"}]}
        ]
      }
    }
  end

  let(:empty_response) { {"data" => {"auditLogEntries" => []}} }

  describe "#assert_graphql_audit_entry" do
    it "passes when the event is present" do
      expect { test_obj.assert_graphql_audit_entry(response_with_entries, event: :update) }.not_to raise_error
    end

    it "raises when the event is absent" do
      expect {
        test_obj.assert_graphql_audit_entry(empty_response, event: :update)
      }.to raise_error(/Expected GraphQL audit entry with event :update/)
    end

    it "passes when touching the given attribute" do
      expect {
        test_obj.assert_graphql_audit_entry(response_with_entries, event: :update, touching: :title)
      }.not_to raise_error
    end

    it "raises when touching an absent attribute" do
      expect {
        test_obj.assert_graphql_audit_entry(response_with_entries, event: :update, touching: :body)
      }.to raise_error(/touching :body/)
    end

    it "passes with item_type filter" do
      expect {
        test_obj.assert_graphql_audit_entry(response_with_entries, event: :create, item_type: "Post")
      }.not_to raise_error
    end

    it "raises with a non-matching item_type" do
      expect {
        test_obj.assert_graphql_audit_entry(response_with_entries, event: :create, item_type: "Comment")
      }.to raise_error(/Expected GraphQL audit entry/)
    end

    it "uses a custom message when provided" do
      expect {
        test_obj.assert_graphql_audit_entry(empty_response, event: :update, message: "my custom message")
      }.to raise_error("my custom message")
    end
  end

  describe "#refute_graphql_audit_entry" do
    it "passes when the event is absent" do
      expect {
        test_obj.refute_graphql_audit_entry(empty_response, event: :update)
      }.not_to raise_error
    end

    it "raises when the event is present" do
      expect {
        test_obj.refute_graphql_audit_entry(response_with_entries, event: :update)
      }.to raise_error(/Expected no GraphQL audit entry with event :update/)
    end

    it "passes when touching a different attribute" do
      expect {
        test_obj.refute_graphql_audit_entry(response_with_entries, event: :update, touching: :body)
      }.not_to raise_error
    end

    it "raises when the attribute is matched" do
      expect {
        test_obj.refute_graphql_audit_entry(response_with_entries, event: :update, touching: :title)
      }.to raise_error(/touching :title/)
    end
  end
end
