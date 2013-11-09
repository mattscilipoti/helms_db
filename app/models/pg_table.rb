class PgTable < ActiveRecord::Base
  self.primary_keys = :schemaname, :tablename

  belongs_to :pg_namespace, primary_key: 'nspname', foreign_key: 'schemaname'

  #scope :non_system, -> { where('schemaname = ANY (current_schemas(false))') }
  #
  #def count
  #  connection.execute 'select count(*) from '
  #end
end
