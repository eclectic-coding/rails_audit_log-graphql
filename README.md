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
    - [auditLogEntriesCount](#auditlogentriescount-int)
    - [Tenant scoping](#tenant-scoping)
  - [Authentication](#authentication)
  - [SchemaPlugin](#schemaplugin)
  - [auditLogReify](#auditlogreify)
  - [Subscriptions](#subscriptions)
    - [AuditLogSubscriptionsMixin](#auditlogsubscriptionsmixin)
    - [auditLogEntryCreated](#auditlogentrycreated)
    - [Broadcaster](#broadcaster)
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
| `actorType` | `String` | — | Filter by actor model class name (e.g. `"User"`) |
| `since` | `ISO8601DateTime` | — | Return entries created at or after this time |
| `until` | `ISO8601DateTime` | — | Return entries created at or before this time |
| `touching` | `String` | — | Filter to entries that changed a specific attribute |
| `orderBy` | `AuditLogEntrySortInput` | `CREATED_AT DESC` | Sort field and direction |
| `forTenant` | `String` | — | Scope to a specific tenant ID; overrides auto-tenant |
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
| `actorType` | `String` | Filter by actor model class name (e.g. `"User"`) |
| `forTenant` | `String` | Scope to a specific tenant ID; overrides auto-tenant |
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

#### `auditLogEntriesCount(...): Int!`

Returns the count of matching audit log entries. Respects auto-tenant when `RailsAuditLog.current_tenant` is configured.

| Argument | Type | Description |
|---|---|---|
| `event` | `String` | Filter by event type (`create`, `update`, `destroy`) |
| `itemType` | `String` | Filter by audited model class name |
| `actorType` | `String` | Filter by actor model class name (e.g. `"User"`) |
| `since` | `ISO8601DateTime` | Count entries created at or after this time |
| `forTenant` | `String` | Scope to a specific tenant ID; overrides auto-tenant |

```graphql
{ auditLogEntriesCount(event: "update", itemType: "Post") }
```

[↑ Back to top](#table-of-contents)

#### Tenant scoping

When `RailsAuditLog.current_tenant` is configured, all queries automatically filter to the current tenant:

```ruby
RailsAuditLog.configure do |c|
  c.current_tenant { Current.tenant_id }
end
```

To override or explicitly specify a tenant per query, use the `forTenant:` argument (available on `auditLogEntry`, `auditLogEntries`, and `auditLogEntriesConnection`):

```graphql
{ auditLogEntries(forTenant: "acme") { id event } }
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

### SchemaPlugin

Include `RailsAuditLog::Graphql::SchemaPlugin` into your schema to enable query protection and dataloader batching in one step:

```ruby
class MySchema < GraphQL::Schema
  include RailsAuditLog::Graphql::SchemaPlugin
  query Types::QueryType
end
```

This applies the following defaults (all overridable via `RailsAuditLog::Graphql.*=`):

| Setting | Default | Description |
|---|---|---|
| `max_complexity` | `200` | Reject queries whose field-complexity sum exceeds this |
| `max_depth` | `10` | Reject queries nested deeper than this |
| `default_max_page_size` | `25` | Assumed page size for connection complexity calculation |

Override in an initializer:

```ruby
RailsAuditLog::Graphql.max_complexity = 500
RailsAuditLog::Graphql.max_depth = 15
```

The plugin also adds `AuditLogActor.record` and `AuditedResource.record` fields — nullable JSON fields that load the actual database record via `RecordByIdSource`, a `GraphQL::Dataloader::Source` that batches loads by class name to eliminate N+1 queries on list responses.

[↑ Back to top](#table-of-contents)

### `auditLogReify(itemType:, itemId:, at:): AuditLogJson`

Reconstructs the attribute state of a record at a given point in time. Returns the attributes as `AuditLogJson`, or `nil` when no entry exists at or before `at` or the record was destroyed at that time. Accepts `forTenant:` and respects auto-tenant.

```graphql
{
  auditLogReify(itemType: "Post", itemId: "42", at: "2026-01-15T12:00:00Z") {
    title
    publishedAt
  }
}
```

[↑ Back to top](#table-of-contents)

### Subscriptions

Requires Action Cable in the host application.

#### AuditLogSubscriptionsMixin

Include `RailsAuditLog::Graphql::Subscriptions::AuditLogSubscriptionsMixin` into your app's `SubscriptionType` to add the `auditLogEntryCreated` field. Your schema must also use `GraphQL::Subscriptions::ActionCableSubscriptions`.

```ruby
# app/graphql/types/subscription_type.rb
class Types::SubscriptionType < Types::BaseObject
  include RailsAuditLog::Graphql::Subscriptions::AuditLogSubscriptionsMixin
end

# app/graphql/my_schema.rb
class MySchema < GraphQL::Schema
  query Types::QueryType
  subscription Types::SubscriptionType
  use GraphQL::Subscriptions::ActionCableSubscriptions
end
```

#### `auditLogEntryCreated`

Fires when a new `RailsAuditLog::AuditLogEntry` is created. Accepts one of two argument combinations:

| Argument | Type | Description |
|---|---|---|
| `itemType` | `String` | Model class name to scope the subscription to |
| `itemId` | `ID` | Record ID to scope the subscription to |
| `actorId` | `ID` | Actor ID — subscribe to all entries by a specific actor |

Subscribe to all changes on a specific record:

```graphql
subscription {
  auditLogEntryCreated(itemType: "Post", itemId: "42") {
    id
    event
    diff { attribute from to }
  }
}
```

Subscribe to all entries by a specific actor:

```graphql
subscription {
  auditLogEntryCreated(actorId: "7") {
    id
    event
    itemType
    itemId
  }
}
```

#### Broadcaster

`RailsAuditLog::Graphql::Subscriptions::Broadcaster` bridges `ActiveSupport::Notifications` (fired by `RailsAuditLog::Streaming::NotificationsAdapter` or `ActiveJobAdapter`) to GraphQL subscription triggers. Start it in an initializer:

```ruby
# config/initializers/rails_audit_log_graphql.rb
RailsAuditLog.configure do |c|
  c.streaming_adapter = RailsAuditLog::Streaming::NotificationsAdapter.new
end

Rails.application.config.after_initialize do
  RailsAuditLog::Graphql::Subscriptions::Broadcaster.new(schema: MySchema).start
end
```

For each entry, the broadcaster triggers:
- `auditLogEntryCreated(itemType:, itemId:)` — notifies record-specific subscribers
- `auditLogEntryCreated(actorId:)` — notifies actor-specific subscribers (when an actor is present)

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