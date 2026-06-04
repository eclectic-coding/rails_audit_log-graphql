# Roadmap

This gem adds a GraphQL API layer on top of [`rails_audit_log`](https://github.com/eclectic-coding/rails_audit_log). It is intentionally a separate gem so that `graphql-ruby` remains an optional dependency for host applications.

---

## 1.0.0 — Stable API

- Full YARD documentation
- **RSpec matchers** — `expect(response).to have_graphql_audit_entry(:update).touching(:title)` 
- **Minitest assertions** — `assert_graphql_audit_entry`
- API stability guarantee — no breaking changes without a major version bump
- Complete README with setup guide, examples, and schema reference
