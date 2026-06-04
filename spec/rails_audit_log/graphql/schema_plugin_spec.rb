# frozen_string_literal: true

RSpec.describe RailsAuditLog::Graphql::SchemaPlugin do
  let(:schema) do
    Class.new(GraphQL::Schema) do
      include RailsAuditLog::Graphql::SchemaPlugin
    end
  end

  it "applies max_complexity from config" do
    expect(schema.max_complexity).to eq(RailsAuditLog::Graphql.max_complexity)
  end

  it "applies max_depth from config" do
    expect(schema.max_depth).to eq(RailsAuditLog::Graphql.max_depth)
  end

  it "applies default_max_page_size from config" do
    expect(schema.default_max_page_size).to eq(RailsAuditLog::Graphql.default_max_page_size)
  end

  it "enables the dataloader" do
    expect(schema.plugins.map(&:first)).to include(GraphQL::Dataloader)
  end
end
