class Postgresql::Index < ActiveRecord::Base
  self.primary_keys = :schemaname, :indexname
  self.table_name = 'pg_indexes'

  belongs_to :namespace, primary_key: 'nspname', foreign_key: 'schemaname'
end
