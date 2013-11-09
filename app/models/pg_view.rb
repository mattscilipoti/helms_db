class PgView < ActiveRecord::Base
  self.primary_keys = :schemaname, :viewname

  belongs_to :pg_namespace, primary_key: 'nspname', foreign_key: 'schemaname'
end

