class PgDatabase < ActiveRecord::Base
  self.primary_key = 'datname'
  self.table_name = 'pg_catalog.pg_database'
  alias_attribute :name, :datname


  def initialize(db_config=nil, commander=nil)
    @db_config = db_config
    @commander = commander
  end

  def commander
    @commander ||= derive_commander(db_config[:adapter])
  end

  def create_role(role_name)
    PgDatabase.connection.execute commander.create_role_cmd(role_name)
    PgRole.find(role_name)
  end

  def derive_commander(adapter)
    case adapter
    when 'postgresql'
      PgCommands.new
    else
      fail "That adapter (#{adapter})is not supported."
    end
  end

  def db_config
    @db_config ||= ActiveRecord::Base.connection_config
  end

  def readonly?
    true
  end

  def roles
    PgRole.all
  end
end

class PgCommands
  def create_role_cmd(role)
    "CREATE ROLE #{role}"
  end
end

class PgRole < ActiveRecord::Base
  self.primary_key = 'rolname'
  self.table_name = 'pg_catalog.pg_roles'
  alias_attribute :name, :rolname
end
