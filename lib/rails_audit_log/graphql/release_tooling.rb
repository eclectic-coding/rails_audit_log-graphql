# frozen_string_literal: true

require "date"

module RailsAuditLog
  module Graphql
    # @api private
    module ReleaseTooling
      module_function

      VERSION_PATTERN = /VERSION = "[^"]+"/
      SEMVER_PATTERN = /\A\d+\.\d+\.\d+(?:[-.][0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?\z/
      UNRELEASED_HEADING = "## [Unreleased]"

      def normalize_version(version)
        normalized = version.to_s.sub(/\Av/, "")
        raise ArgumentError, "version must look like x.y.z" unless normalized.match?(SEMVER_PATTERN)

        normalized
      end

      def update_version_file(contents, version)
        normalized = normalize_version(version)
        raise ArgumentError, "version file does not define VERSION" unless contents.match?(VERSION_PATTERN)

        contents.sub(VERSION_PATTERN, %(VERSION = "#{normalized}"))
      end

      def finalize_changelog(contents, version, date = Date.today)
        normalized = normalize_version(version)
        release_heading = "## [#{normalized}] - #{date.iso8601}"

        raise ArgumentError, "CHANGELOG.md must contain an Unreleased heading" unless contents.include?(UNRELEASED_HEADING)

        if contents.match?(/^## \[#{Regexp.escape(normalized)}\](?: - .+)?$/)
          raise ArgumentError, "CHANGELOG.md already contains #{normalized}"
        end

        contents.sub(UNRELEASED_HEADING, "#{UNRELEASED_HEADING}\n\n#{release_heading}")
      end

      # Removes milestone sections from ROADMAP.md where all feature bullets
      # have been implemented (i.e. no remaining "- **" bullet points).
      def prune_roadmap(contents)
        separator = "\n\n---\n\n"
        sections = contents.split(separator)

        pruned = sections.reject do |section|
          next false unless section.lstrip.match?(/\A## \d+\.\d+\.\d+/)

          !section.include?("- **")
        end

        pruned.join(separator)
      end

      def extract_release_notes(contents, version)
        normalized = normalize_version(version)
        lines = contents.lines
        release_heading = /^## \[#{Regexp.escape(normalized)}\](?: - .+)?$/
        start_index = lines.index { |line| line.match?(release_heading) }

        raise ArgumentError, "CHANGELOG.md is missing release notes for #{normalized}" unless start_index

        body = lines[(start_index + 1)..].take_while { |line| !line.start_with?("## [") }.join.strip
        body = "- No changes listed." if body.empty?

        <<~MARKDOWN
          ## RailsAuditLog::Graphql #{normalized}

          #{body}
        MARKDOWN
      end
    end
  end
end
