class Postgresql::Table < ActiveRecord::Base
  self.primary_keys = :schemaname, :tablename
  self.table_name = 'pg_tables'

  belongs_to :namespace, primary_key: 'nspname', foreign_key: 'schemaname'

  #scope :non_system, -> { where('schemaname = ANY (current_schemas(false))') }
  #
  #def count
  #  connection.execute 'select count(*) from '
  #end
end
