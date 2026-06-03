require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

require "rails_audit_log"
require "rails_audit_log/graphql"

module Dummy
  class Application < Rails::Application
    config.root = File.expand_path("..", __dir__)
    config.load_defaults 8.1
    config.eager_load = false

    config.active_record.encryption.primary_key = "graphql-test-primary-key-0000001"
    config.active_record.encryption.deterministic_key = "graphql-test-deterministic-00001"
    config.active_record.encryption.key_derivation_salt = "graphql-test-kdf-salt-0000001"
  end
end
