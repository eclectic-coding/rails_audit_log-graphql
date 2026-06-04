# frozen_string_literal: true

RSpec.describe RailsAuditLog::Graphql::Subscriptions::AuditLogEntryCreated do
  let(:arguments) { described_class.arguments }

  it "returns non-null AuditLogEntryType" do
    expect(described_class.type.non_null?).to be true
    expect(described_class.type.unwrap).to eq(RailsAuditLog::Graphql::Types::AuditLogEntryType)
  end

  it "defines 3 arguments" do
    expect(arguments.size).to eq(3)
  end

  it "defines itemType as an optional String" do
    arg = arguments.fetch("itemType")
    expect(arg.type.non_null?).to be false
    expect(arg.type.graphql_name).to eq("String")
  end

  it "defines itemId as an optional ID" do
    arg = arguments.fetch("itemId")
    expect(arg.type.non_null?).to be false
    expect(arg.type.graphql_name).to eq("ID")
  end

  it "defines actorId as an optional ID" do
    arg = arguments.fetch("actorId")
    expect(arg.type.non_null?).to be false
    expect(arg.type.graphql_name).to eq("ID")
  end
end
