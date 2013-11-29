class Postgresql::View < ActiveRecord::Base
  self.primary_keys = :schemaname, :viewname
  self.table_name = 'pg_views'

  belongs_to :namespace, primary_key: 'nspname', foreign_key: 'schemaname'
end

