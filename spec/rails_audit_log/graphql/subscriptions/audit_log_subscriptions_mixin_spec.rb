# frozen_string_literal: true

RSpec.describe RailsAuditLog::Graphql::Subscriptions::AuditLogSubscriptionsMixin do
  it "adds auditLogEntryCreated to the including type" do
    type = Class.new(GraphQL::Schema::Object) do
      include RailsAuditLog::Graphql::Subscriptions::AuditLogSubscriptionsMixin
    end

    expect(type.fields).to have_key("auditLogEntryCreated")
  end

  it "wires the field to AuditLogEntryCreated" do
    type = Class.new(GraphQL::Schema::Object) do
      include RailsAuditLog::Graphql::Subscriptions::AuditLogSubscriptionsMixin
    end

    field = type.fields.fetch("auditLogEntryCreated")
    expect(field.resolver).to eq(RailsAuditLog::Graphql::Subscriptions::AuditLogEntryCreated)
  end
end
