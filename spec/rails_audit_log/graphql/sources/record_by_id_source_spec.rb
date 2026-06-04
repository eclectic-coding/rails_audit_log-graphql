# frozen_string_literal: true

require "rails_helper"

RSpec.describe RailsAuditLog::Graphql::Sources::RecordByIdSource do
  describe "#fetch" do
    let(:post1) { Post.create!(title: "Alpha") }
    let(:post2) { Post.create!(title: "Beta") }

    it "batch-loads records by id and returns their attributes" do
      source = described_class.new("Post")
      results = source.fetch([post1.id.to_s, post2.id.to_s])
      expect(results.map { |r| r["title"] }).to eq(["Alpha", "Beta"])
    end

    it "preserves order — returns nil for unknown ids" do
      source = described_class.new("Post")
      results = source.fetch([post1.id.to_s, "999999"])
      expect(results.first["title"]).to eq("Alpha")
      expect(results.last).to be_nil
    end

    it "returns all nils when class_name cannot be constantized" do
      source = described_class.new("NonExistentModel")
      results = source.fetch(["1", "2"])
      expect(results).to eq([nil, nil])
    end
  end
end
