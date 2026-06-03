# RailsAuditLog::Graphql

[![CI](https://github.com/eclectic-coding/rails_audit_log-graphql/actions/workflows/main.yml/badge.svg)](https://github.com/eclectic-coding/rails_audit_log-graphql/actions/workflows/main.yml)
[![Gem Version](https://img.shields.io/gem/v/rails_audit_log-graphql)](https://rubygems.org/gems/rails_audit_log-graphql)
[![Total Downloads](https://img.shields.io/gem/dt/rails_audit_log-graphql)](https://rubygems.org/gems/rails_audit_log-graphql)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.3-CC342D)](https://www.ruby-lang.org)
[![codecov](https://codecov.io/gh/eclectic-coding/rails_audit_log-graphql/graph/badge.svg)](https://codecov.io/gh/eclectic-coding/rails_audit_log-graphql)

A [graphql-ruby](https://graphql-ruby.org) API layer for the [`rails_audit_log`](https://github.com/eclectic-coding/rails_audit_log) gem. Provides ready-made GraphQL types, queries, and subscriptions for querying audit log entries — without coupling `graphql-ruby` to the base gem.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [AuditLogEntryType](#auditlogentrytype)
  - [AuditLogActor](#auditlogactor)
  - [AuditedResource](#auditedresource)
  - [AuditLogDiff](#auditlogdiff)
  - [AuditLogEntriesQueryMixin](#auditlogentriesquerymixin)
    - [auditLogEntry](#auditlogentryid-id-auditlogentry)
    - [auditLogEntries](#auditlogentries-auditlogentry)
    - [auditLogEntriesConnection](#auditlogentriesconnection-auditlogentryconnection)
  - [Authentication](#authentication)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Installation

Add to your application's Gemfile:

```ruby
gem "rails_audit_log"
gem "rails_audit_log-graphql"
```

Then run the install generator to wire up your schema:

```bash
rails g rails_audit_log:graphql:install
```

This injects `include RailsAuditLog::Graphql::Queries::AuditLogEntriesQueryMixin` into `app/graphql/types/query_type.rb`. If that file doesn't exist, the generator prints the line for you to add manually.

[↑ Back to top](#table-of-contents)

## Usage

### AuditLogEntryType

`RailsAuditLog::Graphql::Types::AuditLogEntryType` is a graphql-ruby object type that maps directly to `RailsAuditLog::AuditLogEntry`.

| GraphQL field | Type | Nullable |
|---|---|---|
| `id` | `ID` | no |
| `event` | `String` | no |
| `itemType` | `String` | no |
| `itemId` | `ID` | no |
| `createdAt` | `ISO8601DateTime` | no |
| `objectChanges` | `JSON` | yes |
| `object` | `JSON` | yes |
| `metadata` | `JSON` | yes |
| `reason` | `String` | yes |
| `whodunnitSnapshot` | `String` | yes |
| `actorType` | `String` | yes |
| `actorId` | `ID` | yes |
| `tenantId` | `String` | yes |
| `actor` | `AuditLogActor` | yes |
| `auditedResource` | `AuditedResource` | no |
| `diff` | `[AuditLogDiff!]` | yes |

[↑ Back to top](#table-of-contents)

### AuditLogActor

`RailsAuditLog::Graphql::Types::ActorType` — a polymorphic reference to the actor who performed the audited action. Returned by the `actor` field on `AuditLogEntry`. `null` when no actor was recorded.

| GraphQL field | Type | Nullable |
|---|---|---|
| `id` | `ID` | no |
| `typeName` | `String` | no |

[↑ Back to top](#table-of-contents)

### AuditedResource

`RailsAuditLog::Graphql::Types::AuditedResourceType` — a reference to the model record that was changed. Returned by the `auditedResource` field on `AuditLogEntry`. Always present.

| GraphQL field | Type | Nullable |
|---|---|---|
| `id` | `ID` | no |
| `typeName` | `String` | no |

[↑ Back to top](#table-of-contents)

### AuditLogDiff

`RailsAuditLog::Graphql::Types::DiffType` — a single attribute change parsed from `objectChanges`. Returned as a list by the `diff` field on `AuditLogEntry`. `null` when `objectChanges` is not recorded (e.g. destroy events).

| GraphQL field | Type | Nullable | Description |
|---|---|---|---|
| `attribute` | `String` | no | Name of the changed attribute |
| `from` | `JSON` | yes | Value before the change |
| `to` | `JSON` | yes | Value after the change |

**Example:**

```graphql
{
  auditLogEntries(event: "update") {
    diff {
      attribute
      from
      to
    }
  }
}
```

[↑ Back to top](#table-of-contents)

### AuditLogEntriesQueryMixin

Include `RailsAuditLog::Graphql::Queries::AuditLogEntriesQueryMixin` into your app's `QueryType` to add two fields:

```ruby
# app/graphql/types/query_type.rb
class Types::QueryType < Types::BaseObject
  include RailsAuditLog::Graphql::Queries::AuditLogEntriesQueryMixin
end
```

#### `auditLogEntry(id: ID!): AuditLogEntry`

Fetch a single entry by ID. Returns `nil` if not found.

#### `auditLogEntries(...): [AuditLogEntry!]!`

List entries with optional filters and offset pagination.

| Argument | Type | Default | Description |
|---|---|---|---|
| `event` | `String` | — | Filter by event type (`create`, `update`, `destroy`) |
| `itemType` | `String` | — | Filter by audited model class name |
| `itemId` | `ID` | — | Filter by audited record ID |
| `actorId` | `ID` | — | Filter by actor ID |
| `since` | `ISO8601DateTime` | — | Return entries created at or after this time |
| `until` | `ISO8601DateTime` | — | Return entries created at or before this time |
| `touching` | `String` | — | Filter to entries that changed a specific attribute |
| `orderBy` | `AuditLogEntrySortInput` | `CREATED_AT DESC` | Sort field and direction |
| `page` | `Int` | `1` | Page number (1-based) |
| `perPage` | `Int` | `25` | Results per page |

Results default to `created_at DESC` ordering.

#### `auditLogEntriesConnection(...): AuditLogEntryConnection!`

Same filters as `auditLogEntries`, but returns a [Relay-style connection](https://relay.dev/graphql/connections.htm) for cursor-based pagination.

| Argument | Type | Description |
|---|---|---|
| `event` | `String` | Filter by event type (`create`, `update`, `destroy`) |
| `itemType` | `String` | Filter by audited model class name |
| `itemId` | `ID` | Filter by audited record ID |
| `actorId` | `ID` | Filter by actor ID |
| `first` | `Int` | Return the first N edges after `after` |
| `after` | `String` | Cursor to paginate forward from |
| `last` | `Int` | Return the last N edges before `before` |
| `before` | `String` | Cursor to paginate backward from |

Results are ordered by `created_at DESC`.

**Example — first page:**

```graphql
{
  auditLogEntriesConnection(first: 25) {
    nodes {
      id
      event
      itemType
      itemId
      createdAt
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

**Example — next page using a cursor:**

```graphql
{
  auditLogEntriesConnection(first: 25, after: "eyJpZCI6NDJ9") {
    nodes { id event }
    pageInfo { hasNextPage endCursor }
  }
}
```

[↑ Back to top](#table-of-contents)

### Authentication

If `RailsAuditLog.authenticate` is configured, the block is called with the GraphQL context before every query. Return a truthy value to allow access; return falsy to raise `GraphQL::ExecutionError` with `"Unauthorized"`.

```ruby
RailsAuditLog.configure do |config|
  config.authenticate { |ctx| ctx[:current_user]&.admin? }
end
```

If no authenticate block is set, all queries are permitted.

[↑ Back to top](#table-of-contents)

## Development

```bash
bin/setup         # install dependencies
bundle exec rake  # lint + tests
```

[↑ Back to top](#table-of-contents)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

[↑ Back to top](#table-of-contents)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).