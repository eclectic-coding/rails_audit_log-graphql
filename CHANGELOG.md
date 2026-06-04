## [Unreleased]

## [0.4.0] - 2026-06-04

### Added

- `AuditLogEntryCreated` subscription — `auditLogEntryCreated(itemType:, itemId:)` subscribes to new entries for a specific record; `auditLogEntryCreated(actorId:)` subscribes to all entries by a specific actor
- `AuditLogSubscriptionsMixin` — include into host app's `SubscriptionType` to add the `auditLogEntryCreated` subscription field
- `BaseSubscription` base class for all gem GraphQL subscription types
- `Broadcaster` — call `Broadcaster.new(schema: MySchema).start` in an initializer to relay `rails_audit_log.entry_created` `ActiveSupport::Notifications` events into GraphQL subscription triggers; supports `stop` to unsubscribe

## [0.3.0] - 2026-06-03

### Added

- `ActorType` (`AuditLogActor`) — new object type with `id` and `typeName` fields exposing the polymorphic actor reference; adds `actor: AuditLogActor` field on `AuditLogEntry`
- `AuditedResourceType` (`AuditedResource`) — new object type with `id` and `typeName` fields exposing the audited model reference; adds `auditedResource: AuditedResource!` field on `AuditLogEntry`
- `DiffType` (`AuditLogDiff`) — new object type with `attribute`, `from`, and `to` fields; adds `diff: [AuditLogDiff!]` field on `AuditLogEntry` parsed from `objectChanges`

## [0.2.0] - 2026-06-03

### Added

- `auditLogEntriesConnection` — new Relay-style cursor-paginated field returning `AuditLogEntryConnection!` with `nodes`, `edges`, `pageInfo`, and `first`/`after`/`last`/`before` arguments; accepts the same filters as `auditLogEntries`
- `since:` and `until:` (`ISO8601DateTime`) arguments on both `auditLogEntries` and `auditLogEntriesConnection` for filtering by creation time range
- `touching:` (`String`) argument on both `auditLogEntries` and `auditLogEntriesConnection` — filters to entries whose `object_changes` include the named attribute
- `orderBy:` (`AuditLogEntrySortInput`) argument on both `auditLogEntries` and `auditLogEntriesConnection` — accepts `{ field: CREATED_AT, direction: ASC | DESC }`; defaults to `CREATED_AT DESC`
- `AuditLogEntrySortInput` input object type, `AuditLogEntrySortField` enum, and `SortDirection` enum added to the schema

## [0.1.0] - 2026-06-03

### Added

- `AuditLogEntryType` GraphQL object type exposing all 13 `RailsAuditLog::AuditLogEntry` fields
- `BaseObject` base class for all gem GraphQL types
- `AuditLogEntriesQueryMixin` — include into host app's `QueryType` to add `auditLogEntry(id:)` and `auditLogEntries(event:, itemType:, itemId:, actorId:, page:, perPage:)` queries
- Authentication support — `RailsAuditLog.authenticate` is respected; block receives the GraphQL context and raises `GraphQL::ExecutionError` when it returns falsy
- `rails g rails_audit_log:graphql:install` generator — injects `AuditLogEntriesQueryMixin` into `app/graphql/types/query_type.rb`

