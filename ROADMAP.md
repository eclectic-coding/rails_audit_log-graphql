# Roadmap

This gem adds a GraphQL API layer on top of [`rails_audit_log`](https://github.com/eclectic-coding/rails_audit_log). It is intentionally a separate gem so that `graphql-ruby` remains an optional dependency for host applications.

---

## 0.1.0 — Core Types & Queries _(enough to get started)_

The minimum useful surface: drop in the gem, mount the types, and start querying audit entries.

- **`AuditLogEntryType`** — GraphQL object type exposing all entry fields (`id`, `event`, `itemType`, `itemId`, `objectChanges`, `metadata`, `reason`, `whodunnitSnapshot`, `actorType`, `actorId`, `createdAt`)
- **`AuditLogEntriesQueryMixin`** — include into the host app's `QueryType` to add:
  - `auditLogEntry(id:)` — fetch a single entry by ID
  - `auditLogEntries(event:, itemType:, itemId:, actorId:)` — filtered list with offset pagination
- **Authentication** — respects `RailsAuditLog.authenticate` if configured; raises `GraphQL::ExecutionError` on unauthorized access
- **Generator** — `rails g rails_audit_log:graphql:install` to scaffold the mixin include into the host app's schema

---

## 0.2.0 — Filtering & Connections

- **Time-range filters** — `since:` and `until:` arguments on `auditLogEntries`
- **`touching:` filter** — narrow results to entries that changed a specific attribute
- **Relay-style connection** — replace offset pagination with cursor-based `AuditLogEntryConnection` for forward/backward pagination
- **Sorting** — `orderBy: { field: CREATED_AT, direction: DESC }`

---

## 0.3.0 — Actor & Resource Resolver Types

- **`ActorType`** — resolve the polymorphic `actor` to the concrete type in the host app's schema (requires a configurable type resolver proc)
- **`AuditedResourceType`** — resolve `item_type`/`item_id` to the concrete audited model type
- **`diffType`** — structured `{ from, to }` diff type instead of raw `objectChanges` JSON

---

## 0.4.0 — Subscriptions

Requires Action Cable in the host application.

- **`auditLogEntryCreated(itemType:, itemId:)`** — subscribe to new entries for a specific record
- **`auditLogEntryCreated(actorId:)`** — subscribe to all entries by a specific actor
- Hooks into `RailsAuditLog::Streaming::NotificationsAdapter` to trigger broadcasts

---

## 0.5.0 — Multi-tenancy & Advanced Filtering

- **Tenant scoping** — automatically scope queries via `RailsAuditLog.current_tenant` when configured
- **`forTenant:` argument** — explicit tenant filter on `auditLogEntries`
- **Aggregations** — `auditLogEntriesCount(event:, itemType:, since:)` for dashboard metrics

---

## 1.0.0 — Stable API

- Full YARD documentation
- **RSpec matchers** — `expect(response).to have_graphql_audit_entry(:update).touching(:title)` 
- **Minitest assertions** — `assert_graphql_audit_entry`
- API stability guarantee — no breaking changes without a major version bump
- Complete README with setup guide, examples, and schema reference
