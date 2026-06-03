# frozen_string_literal: true

require "bundler/gem_tasks"
require "bundler/audit/task"
require "rspec/core/rake_task"
require "standard/rake"

Bundler::Audit::Task.new
RSpec::Core::RakeTask.new(:spec)

task default: [:standard, :spec]
