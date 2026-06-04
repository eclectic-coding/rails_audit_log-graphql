# frozen_string_literal: true

RSpec.describe RailsAuditLog::Graphql::Types::ActorType do
  let(:fields) { described_class.fields }

  it "has the correct GraphQL name" do
    expect(described_class.graphql_name).to eq("AuditLogActor")
  end

  it "exposes exactly 3 fields" do
    expect(fields.size).to eq(3)
  end

  it "exposes id as a non-null ID" do
    field = fields.fetch("id")
    expect(field.type.non_null?).to be true
    expect(field.type.unwrap.graphql_name).to eq("ID")
  end

  it "exposes typeName as a non-null String" do
    field = fields.fetch("typeName")
    expect(field.type.non_null?).to be true
    expect(field.type.unwrap.graphql_name).to eq("String")
  end

  it "exposes record as a nullable JSON field" do
    field = fields.fetch("record")
    expect(field.type.non_null?).to be false
    expect(field.type.graphql_name).to eq("JSON")
  end
end
