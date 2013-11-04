dep 'setup' do
  app_name = 'db_info'
  requires 'setup db'.with(app_name: app_name)
end

dep 'setup db', :app_name, :db_name do
  db_name.default!("#{app_name}_development")
  requires 'setup db user'.with(db_name: db_name, user: app_name)
end

dep 'setup db user', :db_name, :user do
  def psql(sql_cmd)
    cmd = %(psql -d #{db_name} -c "#{sql_cmd}")
    shell cmd
  end

  met? {
    psql(%Q{SELECT u.usename FROM pg_catalog.pg_user u WHERE u.usename = '#{user}'}) =~ /#{user}/
  }
  meet {
    psql "CREATE USER #{user} WITH CREATEDB"
  }
end
