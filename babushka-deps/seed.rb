require 'debugger'

unless defined?(PgNamespace)
  require './config/environment'
end

dep 'seed' do
  requires 'seed namespace'
end

dep 'seed namespace', :namespace do
  namespace.default!('seeded_namespace')
  met? {
    found = PgNamespace.find_by_nspname(namespace.to_s)
    debugger
    found && found.pg_tables.count > 0
  }

  meet {
    found = PgNamespace.create!(name: name)
    found.migrate
  }
end
