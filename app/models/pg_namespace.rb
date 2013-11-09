class PgNamespace < ActiveRecord::Base
  include Concerns::DbNamespaceable
  self.primary_key = 'nspname'
  self.table_name = 'pg_namespace'

  #has_many :pg_classes, foreign_key: 'relnamespace', primary_key: 'oid'
  has_many :pg_indices, class_name: 'PgIndex', foreign_key: 'schemaname', primary_key: 'nspname'
  has_many :pg_indexes, class_name: 'PgIndex', foreign_key: 'schemaname', primary_key: 'nspname'
  has_many :pg_tables, foreign_key: 'schemaname', primary_key: 'nspname'
  has_many :pg_views, foreign_key: 'schemaname', primary_key: 'nspname'

  def self.create!(attributes = {}, options = {}, &block)
    attributes.assert_valid_keys(:name)
    create_namespace(attributes[:name])
  end

  def self.create_namespace(data_namespace)
    logger.warn "Creating new db namespace '#{data_namespace}'."
    schema_sql = "create schema #{data_namespace}"
    #use psql, since current connection should not have rights to create namespace
    #cmd = %(psql -q -d #{database} -c "#{schema_sql}" 2>&1)
    #result = `#{cmd}`

    #fail "Problems creating namespace: #{result}" if result =~ /ERROR/i
    connection.execute(schema_sql)
    find(data_namespace)
  end

  def self.current_namespace
    raise "Multiple Namespaces" if current_namespaces.size > 1
    current_namespaces.first
  end

  # returns the namespaces listed in the current schema_search_path
  def self.current_namespaces
    connection.schema_search_path.split(',').collect do |search_item|
      PgNamespace.find_by_nspname(search_item)
    end.compact
  end

  def self.database
    connection_config[:database]
  end

  def self.drop_namespace(data_namespace)
    fail ArgumentError.new("You can not drop the current namespace (#{connection.schema_search_path})") if connection.schema_search_path =~ /#{data_namespace}/
    logger.warn "Dropping db namespace '#{data_namespace}'."
    connection.execute("drop schema if exists #{data_namespace} cascade")
    # TODO: is clear needed?
    connection.schema_cache.clear!
  end

  def self.reset
    connection.schema_search_path = '"$user",public'
  end


  def change_owner(new_owner)
    connection.execute change_owner_cmd
  end

  def change_owner_cmd(new_owner)
    "ALTER #{nspname} OWNER TO #{new_owner}"
  end

  def data_namespace
    nspname
  end

  def migrate!(suppress_output = :suppress)
    activate!

    #suppress_output_stream(suppress_output) do
    # copied from activerecord's rake db:migrate
    ActiveRecord::Migration.verbose = !suppress_output
    ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths, ENV["VERSION"] ? ENV["VERSION"].to_i : nil) do |migration|
      ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
    end
    #end
    self
  end
end
