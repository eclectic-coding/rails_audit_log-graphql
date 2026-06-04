# frozen_string_literal: true

require_relative "testing/rspec_matchers"
require_relative "testing/minitest_assertions"

module RailsAuditLog
  module Graphql
    # Test helpers for asserting GraphQL audit log entries in query responses.
    #
    # Require this file from your test helper to load both RSpec matchers and
    # Minitest assertions:
    #
    #   # spec/spec_helper.rb or test/test_helper.rb
    #   require "rails_audit_log/graphql/testing"
    #
    # Then include the appropriate module for your test framework:
    #
    #   # RSpec
    #   RSpec.configure do |config|
    #     config.include RailsAuditLog::Graphql::Testing::RSpecMatchers
    #   end
    #
    #   # Minitest
    #   class ActiveSupport::TestCase
    #     include RailsAuditLog::Graphql::Testing::MinitestAssertions
    #   end
    module Testing
    end
  end
end
