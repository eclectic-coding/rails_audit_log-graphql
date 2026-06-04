# frozen_string_literal: true

RSpec.describe RailsAuditLog::Graphql::Types::AuditLogEntryType do
  let(:fields) { described_class.fields }

  it "has the correct GraphQL name" do
    expect(described_class.graphql_name).to eq("AuditLogEntry")
  end

  it "exposes exactly 16 fields" do
    expect(fields.size).to eq(16)
  end

  describe "non-null fields" do
    it "exposes id as a non-null ID" do
      field = fields.fetch("id")
      expect(field.type.non_null?).to be true
      expect(field.type.unwrap.graphql_name).to eq("ID")
    end

    it "exposes event as a non-null String" do
      field = fields.fetch("event")
      expect(field.type.non_null?).to be true
      expect(field.type.unwrap.graphql_name).to eq("String")
    end

    it "exposes itemType as a non-null String" do
      field = fields.fetch("itemType")
      expect(field.type.non_null?).to be true
      expect(field.type.unwrap.graphql_name).to eq("String")
    end

    it "exposes itemId as a non-null ID" do
      field = fields.fetch("itemId")
      expect(field.type.non_null?).to be true
      expect(field.type.unwrap.graphql_name).to eq("ID")
    end

    it "exposes createdAt as a non-null ISO8601DateTime" do
      field = fields.fetch("createdAt")
      expect(field.type.non_null?).to be true
      expect(field.type.unwrap.graphql_name).to eq("ISO8601DateTime")
    end
  end

  describe "nullable AuditLogJson fields" do
    %w[objectChanges object metadata].each do |field_name|
      it "exposes #{field_name} as nullable AuditLogJson" do
        field = fields.fetch(field_name)
        expect(field.type.non_null?).to be false
        expect(field.type.graphql_name).to eq("AuditLogJson")
      end
    end
  end

  describe "nullable String fields" do
    %w[reason whodunnitSnapshot tenantId actorType].each do |field_name|
      it "exposes #{field_name} as nullable String" do
        field = fields.fetch(field_name)
        expect(field.type.non_null?).to be false
        expect(field.type.graphql_name).to eq("String")
      end
    end
  end

  it "exposes actorId as nullable ID" do
    field = fields.fetch("actorId")
    expect(field.type.non_null?).to be false
    expect(field.type.graphql_name).to eq("ID")
  end

  it "exposes actor as nullable AuditLogActor" do
    field = fields.fetch("actor")
    expect(field.type.non_null?).to be false
    expect(field.type.graphql_name).to eq("AuditLogActor")
  end

  it "exposes auditedResource as non-null AuditedResource" do
    field = fields.fetch("auditedResource")
    expect(field.type.non_null?).to be true
    expect(field.type.unwrap.graphql_name).to eq("AuditedResource")
  end

  it "exposes diff as nullable list of non-null AuditLogDiff" do
    field = fields.fetch("diff")
    expect(field.type.non_null?).to be false
    expect(field.type.to_type_signature).to eq("[AuditLogDiff!]")
  end
end
