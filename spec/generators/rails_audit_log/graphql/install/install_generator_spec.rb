# frozen_string_literal: true

require "spec_helper"
require "tempfile"
require "rails/generators"
require "rails/generators/testing/behavior"
require "rails/generators/testing/assertions"
require "generators/rails_audit_log/graphql/install/install_generator"

RSpec.describe RailsAuditLog::Generators::Graphql::InstallGenerator do
  include Rails::Generators::Testing::Behavior
  include Rails::Generators::Testing::Assertions
  include FileUtils

  tests RailsAuditLog::Generators::Graphql::InstallGenerator
  destination File.expand_path("../../../../../tmp/generator", __dir__)

  before { prepare_destination }

  it "has the correct description" do
    expect(described_class.desc).to include("AuditLogEntriesQueryMixin")
  end

  context "when app/graphql/types/query_type.rb exists" do
    before do
      mkdir_p "#{destination_root}/app/graphql/types"
      File.write("#{destination_root}/app/graphql/types/query_type.rb", <<~RUBY)
        # frozen_string_literal: true

        class Types::QueryType < Types::BaseObject
        end
      RUBY
      run_generator
    end

    it "injects the mixin include" do
      content = File.read("#{destination_root}/app/graphql/types/query_type.rb")
      expect(content).to include("include RailsAuditLog::Graphql::Queries::AuditLogEntriesQueryMixin")
    end

    it "places the include inside the class body" do
      content = File.read("#{destination_root}/app/graphql/types/query_type.rb")
      expect(content).to match(/class Types::QueryType.*\n\s+include RailsAuditLog/m)
    end
  end

  context "when app/graphql/types/query_type.rb is missing" do
    it "does not raise an error" do
      expect { run_generator }.not_to raise_error
    end
  end
end
