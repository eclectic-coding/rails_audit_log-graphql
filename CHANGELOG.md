## [Unreleased]

### Added

- `AuditLogEntryType` GraphQL object type exposing all 13 `RailsAuditLog::AuditLogEntry` fields
- `BaseObject` base class for all gem GraphQL types
- `AuditLogEntriesQueryMixin` — include into host app's `QueryType` to add `auditLogEntry(id:)` and `auditLogEntries(event:, itemType:, itemId:, actorId:, page:, perPage:)` queries

