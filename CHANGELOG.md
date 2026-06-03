## [Unreleased]

### Added

- `auditLogEntriesConnection` — new Relay-style cursor-paginated field returning `AuditLogEntryConnection!` with `nodes`, `edges`, `pageInfo`, and `first`/`after`/`last`/`before` arguments; accepts the same filters as `auditLogEntries`
- `since:` and `until:` (`ISO8601DateTime`) arguments on both `auditLogEntries` and `auditLogEntriesConnection` for filtering by creation time range
- `touching:` (`String`) argument on both `auditLogEntries` and `auditLogEntriesConnection` — filters to entries whose `object_changes` include the named attribute

## [0.1.0] - 2026-06-03

### Added

- `AuditLogEntryType` GraphQL object type exposing all 13 `RailsAuditLog::AuditLogEntry` fields
- `BaseObject` base class for all gem GraphQL types
- `AuditLogEntriesQueryMixin` — include into host app's `QueryType` to add `auditLogEntry(id:)` and `auditLogEntries(event:, itemType:, itemId:, actorId:, page:, perPage:)` queries
- Authentication support — `RailsAuditLog.authenticate` is respected; block receives the GraphQL context and raises `GraphQL::ExecutionError` when it returns falsy
- `rails g rails_audit_log:graphql:install` generator — injects `AuditLogEntriesQueryMixin` into `app/graphql/types/query_type.rb`

