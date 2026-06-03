# Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eclectic-coding/rails_audit_log-graphql.

## Development Setup

```bash
git clone https://github.com/eclectic-coding/rails_audit_log-graphql.git
cd rails_audit_log-graphql
bin/setup
```

## Running the Test Suite

```bash
bundle exec rake          # lint (StandardRB) + tests — this is what CI runs
bundle exec rspec         # tests only
bundle exec standardrb    # lint only
```

All pull requests must pass the full suite before merging.

## Branch Workflow

- Branch from `main` using a `feat/*` or `chore/*` prefix
- One logical change per branch
- Open a pull request against `main`; CI must be green before merge

## Changelog

Add an entry under `## [Unreleased]` in `CHANGELOG.md` with every PR. Use the appropriate section:

- `### Added` — new functionality
- `### Changed` — changes to existing behaviour
- `### Fixed` — bug fixes

## Roadmap

When a feature listed in `ROADMAP.md` is completed, remove its bullet in the same PR that implements it.

## Code Style

This project uses [Standard Ruby](https://standardrb.com) (`standard` gem). Run `bundle exec rake standard:fix` to auto-correct violations before committing.

## RBS Signatures

Update `sig/rails_audit_log/graphql.rbs` when adding or changing public classes and modules.

## Releasing

Releases are managed by the maintainer. Do not bump `version.rb` in feature PRs.