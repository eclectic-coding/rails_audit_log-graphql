# RailsAuditLog::Graphql

[![CI](https://github.com/eclectic-coding/rails_audit_log-graphql/actions/workflows/main.yml/badge.svg)](https://github.com/eclectic-coding/rails_audit_log-graphql/actions/workflows/main.yml)
[![Gem Version](https://img.shields.io/gem/v/rails_audit_log-graphql)](https://rubygems.org/gems/rails_audit_log-graphql)
[![Total Downloads](https://img.shields.io/gem/dt/rails_audit_log-graphql)](https://rubygems.org/gems/rails_audit_log-graphql)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.3-CC342D)](https://www.ruby-lang.org)
[![codecov](https://codecov.io/gh/eclectic-coding/rails_audit_log-graphql/graph/badge.svg)](https://codecov.io/gh/eclectic-coding/rails_audit_log-graphql)

A [graphql-ruby](https://graphql-ruby.org) API layer for the [`rails_audit_log`](https://github.com/eclectic-coding/rails_audit_log) gem. Provides ready-made GraphQL types, queries, and subscriptions for querying audit log entries — without coupling `graphql-ruby` to the base gem.

## Installation

Add to your application's Gemfile:

```ruby
gem "rails_audit_log"
gem "rails_audit_log-graphql"
```

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
| `page` | `Int` | `1` | Page number (1-based) |
| `perPage` | `Int` | `25` | Results per page |

Results are ordered by `created_at DESC`.

## Development

```bash
bin/setup       # install dependencies
bundle exec rake  # lint + tests
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eclectic-coding/rails_audit_log-graphql.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
