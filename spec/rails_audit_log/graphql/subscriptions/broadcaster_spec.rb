# frozen_string_literal: true

RSpec.describe RailsAuditLog::Graphql::Subscriptions::Broadcaster do
  let(:subscriptions) { instance_double(GraphQL::Subscriptions, trigger: nil) }
  let(:schema) { class_double("GraphQL::Schema", subscriptions: subscriptions) }

  subject(:broadcaster) { described_class.new(schema: schema) }

  describe "#start" do
    after { broadcaster.stop }

    it "subscribes to rails_audit_log.entry_created notifications" do
      broadcaster.start
      expect(
        ActiveSupport::Notifications.notifier.listening?("rails_audit_log.entry_created")
      ).to be true
    end

    it "calls broadcast when a notification is fired" do
      entry = RailsAuditLog::AuditLogEntry.new(item_type: "Post", item_id: 1)
      allow(subscriptions).to receive(:trigger)
      broadcaster.start

      ActiveSupport::Notifications.instrument("rails_audit_log.entry_created", entry: entry)

      expect(subscriptions).to have_received(:trigger).with(
        "audit_log_entry_created",
        {item_type: "Post", item_id: "1"},
        entry
      )
    end
  end

  describe "#broadcast" do
    let(:entry) do
      RailsAuditLog::AuditLogEntry.new(
        item_type: "Post", item_id: 42, actor_id: 7, actor_type: "User"
      )
    end

    it "triggers a record-specific subscription" do
      expect(subscriptions).to receive(:trigger).with(
        "audit_log_entry_created",
        {item_type: "Post", item_id: "42"},
        entry
      )
      allow(subscriptions).to receive(:trigger)
      broadcaster.broadcast(entry)
    end

    it "triggers an actor-specific subscription when actor_id is present" do
      allow(subscriptions).to receive(:trigger)
      expect(subscriptions).to receive(:trigger).with(
        "audit_log_entry_created",
        {actor_id: "7"},
        entry
      )
      broadcaster.broadcast(entry)
    end

    context "when actor_id is nil" do
      let(:entry) do
        RailsAuditLog::AuditLogEntry.new(item_type: "Post", item_id: 42)
      end

      it "only triggers the record-specific subscription" do
        expect(subscriptions).to receive(:trigger).once.with(
          "audit_log_entry_created",
          {item_type: "Post", item_id: "42"},
          entry
        )
        broadcaster.broadcast(entry)
      end
    end
  end

  describe "#stop" do
    it "unsubscribes from notifications" do
      broadcaster.start
      broadcaster.stop
      expect(
        ActiveSupport::Notifications.notifier.listening?("rails_audit_log.entry_created")
      ).to be false
    end
  end
end
