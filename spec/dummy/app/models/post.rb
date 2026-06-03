class Post < ApplicationRecord
  include RailsAuditLog::Auditable

  audit_log
end
