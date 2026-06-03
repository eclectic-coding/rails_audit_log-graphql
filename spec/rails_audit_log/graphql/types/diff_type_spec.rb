# frozen_string_literal: true

RSpec.describe RailsAuditLog::Graphql::Types::DiffType do
  let(:fields) { described_class.fields }

  it "has the correct GraphQL name" do
    expect(described_class.graphql_name).to eq("AuditLogDiff")
  end

  it "exposes exactly 3 fields" do
    expect(fields.size).to eq(3)
  end

  it "exposes attribute as a non-null String" do
    field = fields.fetch("attribute")
    expect(field.type.non_null?).to be true
    expect(field.type.unwrap.graphql_name).to eq("String")
  end

  it "exposes from as nullable JSON" do
    field = fields.fetch("from")
    expect(field.type.non_null?).to be false
    expect(field.type.graphql_name).to eq("JSON")
  end

  it "exposes to as nullable JSON" do
    field = fields.fetch("to")
    expect(field.type.non_null?).to be false
    expect(field.type.graphql_name).to eq("JSON")
  end
end
