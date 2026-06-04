# Roadmap

This gem adds a GraphQL API layer on top of [`rails_audit_log`](https://github.com/eclectic-coding/rails_audit_log). It is intentionally a separate gem so that `graphql-ruby` remains an optional dependency for host applications.

---

## 0.6.0 — Performance & Safety

- **Dataloader batch loading** — batch-resolve polymorphic `actor` and `item` associations using graphql-ruby's `dataloader` to eliminate N+1 queries on list responses
- **`auditLogReify` query** — `auditLogReify(itemType:, itemId:, at:)` returns the reconstructed object state as JSON at a given point in time, backed by `RailsAuditLog.version_at`
- **Query complexity & depth limits** — built-in defaults (`max_complexity`, `max_depth`) with a config override (`RailsAuditLogGraphql.max_complexity = 200`) to protect against expensive queries before the API is declared stable
- **`AuditLogJsonScalar`** — proper JSON scalar type for `objectChanges` and `metadata` fields, replacing opaque String serialization and making the schema self-documenting

---

## 1.0.0 — Stable API

- Full YARD documentation
- **RSpec matchers** — `expect(response).to have_graphql_audit_entry(:update).touching(:title)` 
- **Minitest assertions** — `assert_graphql_audit_entry`
- API stability guarantee — no breaking changes without a major version bump
- Complete README with setup guide, examples, and schema reference
