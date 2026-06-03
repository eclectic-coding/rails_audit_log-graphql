alice = User.create!(name: "Alice")
bob = User.create!(name: "Bob")
carol = User.create!(name: "Carol")

# Create 20 posts as Alice (20 create entries)
posts = RailsAuditLog.with_actor(alice) do
  20.times.map { |i| Post.create!(title: "Post #{i + 1}", body: "Body of post #{i + 1}") }
end

# Update the first 15 posts as Bob (15 update entries)
RailsAuditLog.with_actor(bob) do
  posts.first(15).each_with_index do |post, i|
    post.update!(title: "Post #{i + 1} (edited by Bob)")
  end
end

# Update 10 of those again as Carol (10 update entries)
RailsAuditLog.with_actor(carol) do
  posts.first(10).each_with_index do |post, i|
    post.update!(title: "Post #{i + 1} (final)")
  end
end

# Destroy 5 posts as Alice (5 destroy entries)
RailsAuditLog.with_actor(alice) do
  posts.last(5).each(&:destroy)
end

puts "Seeded #{User.count} users, #{Post.count} posts, #{RailsAuditLog::AuditLogEntry.count} audit log entries"
