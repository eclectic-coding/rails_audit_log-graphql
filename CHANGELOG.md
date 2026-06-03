## [Unreleased]

### Added

- Relay-style cursor pagination — `auditLogEntries` now returns `AuditLogEntryConnection` with `nodes`, `edges`, and `pageInfo` (`hasNextPage`, `hasPreviousPage`, `startCursor`, `endCursor`)
- `first`, `after`, `last`, `before` cursor arguments on `auditLogEntries` (standard Relay connection arguments)

### Changed

- `auditLogEntries` return type changed from `[AuditLogEntry!]!` to `AuditLogEntryConnection!` — callers must now select `nodes { ... }` or `edges { node { ... } cursor }` instead of selecting fields directly on the list
- `page` and `perPage` arguments removed from `auditLogEntries`

## [0.1.0] - 2026-06-03

### Added

- `AuditLogEntryType` GraphQL object type exposing all 13 `RailsAuditLog::AuditLogEntry` fields
- `BaseObject` base class for all gem GraphQL types
- `AuditLogEntriesQueryMixin` — include into host app's `QueryType` to add `auditLogEntry(id:)` and `auditLogEntries(event:, itemType:, itemId:, actorId:, page:, perPage:)` queries
- Authentication support — `RailsAuditLog.authenticate` is respected; block receives the GraphQL context and raises `GraphQL::ExecutionError` when it returns falsy
- `rails g rails_audit_log:graphql:install` generator — injects `AuditLogEntriesQueryMixin` into `app/graphql/types/query_type.rb`

