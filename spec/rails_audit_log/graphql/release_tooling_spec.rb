# frozen_string_literal: true

require "spec_helper"
require "rails_audit_log/graphql/release_tooling"

RSpec.describe RailsAuditLog::Graphql::ReleaseTooling do
  describe ".normalize_version" do
    it "accepts a plain semver string" do
      expect(described_class.normalize_version("1.2.3")).to eq("1.2.3")
    end

    it "strips a leading v prefix" do
      expect(described_class.normalize_version("v1.2.3")).to eq("1.2.3")
    end

    it "raises for non-semver input" do
      expect { described_class.normalize_version("bad") }
        .to raise_error(ArgumentError, /x\.y\.z/)
    end
  end

  describe ".update_version_file" do
    let(:contents) { %(# frozen_string_literal: true\n\nVERSION = "0.1.0"\n) }

    it "replaces the version constant" do
      result = described_class.update_version_file(contents, "0.2.0")
      expect(result).to include('VERSION = "0.2.0"')
    end

    it "raises when VERSION is missing" do
      expect { described_class.update_version_file("no version here", "0.2.0") }
        .to raise_error(ArgumentError, /does not define VERSION/)
    end
  end

  describe ".finalize_changelog" do
    let(:contents) do
      <<~MD
        ## [Unreleased]

        ### Added

        - Something new
      MD
    end

    it "inserts the versioned heading below Unreleased" do
      result = described_class.finalize_changelog(contents, "0.1.0", Date.new(2026, 6, 3))
      expect(result).to include("## [0.1.0] - 2026-06-03")
      expect(result).to include("## [Unreleased]")
    end

    it "raises when Unreleased heading is missing" do
      expect { described_class.finalize_changelog("no heading", "0.1.0") }
        .to raise_error(ArgumentError, /Unreleased/)
    end

    it "raises when version already exists" do
      contents_with_version = contents + "\n## [0.1.0] - 2026-01-01\n"
      expect { described_class.finalize_changelog(contents_with_version, "0.1.0") }
        .to raise_error(ArgumentError, /already contains/)
    end
  end

  describe ".prune_roadmap" do
    let(:empty_section) do
      <<~MD
        ## 0.1.0 — Done

        All features shipped.
      MD
    end

    let(:active_section) do
      <<~MD
        ## 0.2.0 — In Progress

        - **Pending feature** — not done yet
      MD
    end

    it "removes version sections with no remaining bullets" do
      contents = [empty_section, active_section].join("\n\n---\n\n")
      result = described_class.prune_roadmap(contents)
      expect(result).not_to include("0.1.0 — Done")
      expect(result).to include("0.2.0 — In Progress")
    end

    it "keeps version sections that still have bullets" do
      contents = active_section
      result = described_class.prune_roadmap(contents)
      expect(result).to include("0.2.0 — In Progress")
    end

    it "is a no-op when nothing to prune" do
      result = described_class.prune_roadmap(active_section)
      expect(result).to eq(active_section)
    end
  end

  describe ".extract_release_notes" do
    let(:contents) do
      <<~MD
        ## [Unreleased]

        ## [0.1.0] - 2026-06-03

        ### Added

        - AuditLogEntryType

        ## [0.0.1] - 2026-01-01

        - Initial release
      MD
    end

    it "extracts notes for the given version" do
      notes = described_class.extract_release_notes(contents, "0.1.0")
      expect(notes).to include("## RailsAuditLog::Graphql 0.1.0")
      expect(notes).to include("AuditLogEntryType")
    end

    it "does not include notes from other versions" do
      notes = described_class.extract_release_notes(contents, "0.1.0")
      expect(notes).not_to include("Initial release")
    end

    it "raises when version is missing from changelog" do
      expect { described_class.extract_release_notes(contents, "9.9.9") }
        .to raise_error(ArgumentError, /missing release notes/)
    end
  end
end
