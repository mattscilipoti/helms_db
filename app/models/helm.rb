class Helm
  def self.find_database(db_config)
    adapter = db_config.fetch(:adapter)
    case adapter
    when 'postgresql'
      Postgresql::Database.find(db_config.fetch(:database))
    else
      fail ArgumentError, "Unsupported adapter (#{adapter})."
    end
  end
end
