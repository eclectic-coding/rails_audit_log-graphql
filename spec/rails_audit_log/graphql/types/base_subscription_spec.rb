# frozen_string_literal: true

RSpec.describe RailsAuditLog::Graphql::Types::BaseSubscription do
  it "inherits from GraphQL::Schema::Subscription" do
    expect(described_class.superclass).to eq(GraphQL::Schema::Subscription)
  end
end
