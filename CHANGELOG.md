## [Unreleased]

### Added

- `AuditLogEntryType` GraphQL object type exposing all 13 `RailsAuditLog::AuditLogEntry` fields
- `BaseObject` base class for all gem GraphQL types
- `AuditLogEntriesQueryMixin` — include into host app's `QueryType` to add `auditLogEntry(id:)` and `auditLogEntries(event:, itemType:, itemId:, actorId:, page:, perPage:)` queries
- Authentication support — `RailsAuditLog.authenticate` is respected; block receives the GraphQL context and raises `GraphQL::ExecutionError` when it returns falsy
- `rails g rails_audit_log:graphql:install` generator — injects `AuditLogEntriesQueryMixin` into `app/graphql/types/query_type.rb`

