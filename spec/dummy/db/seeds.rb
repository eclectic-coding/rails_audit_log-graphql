alice = User.create!(name: "Alice")
bob = User.create!(name: "Bob")

RailsAuditLog.with_actor(alice) do
  Post.create!(title: "First post", body: "Hello world")
  Post.create!(title: "Second post", body: "Another post")
end

RailsAuditLog.with_actor(bob) do
  Post.last.update!(title: "Updated by Bob")
  Post.first.destroy
end

puts "Seeded #{RailsAuditLog::AuditLogEntry.count} audit log entries"
