# frozen_string_literal: true

RSpec.describe RailsAuditLog::Graphql::Types::AuditLogJsonScalar do
  it "has the correct GraphQL name" do
    expect(described_class.graphql_name).to eq("AuditLogJson")
  end

  describe ".coerce_input" do
    it "passes through a Hash unchanged" do
      input = {"key" => "value"}
      expect(described_class.coerce_input(input, nil)).to eq(input)
    end

    it "parses a JSON string" do
      expect(described_class.coerce_input('{"key":"value"}', nil)).to eq("key" => "value")
    end

    it "raises GraphQL::CoercionError for invalid JSON" do
      expect { described_class.coerce_input("not-json", nil) }
        .to raise_error(GraphQL::CoercionError)
    end
  end

  describe ".coerce_result" do
    it "returns the value as-is" do
      value = {"key" => "value"}
      expect(described_class.coerce_result(value, nil)).to eq(value)
    end
  end
end
