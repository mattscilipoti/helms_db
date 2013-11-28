module Concerns::DbNamespaceable
  extend ActiveSupport::Concern

  def activate!
    self.class.activate!(data_namespace)
    self
  end

  def current_search_path
    self.class.current_search_path
  end

  # template method
  def data_namespace
    fail "Implement in child."
  end

  def use
    self.class.use(data_namespace) do
      yield self
    end
  end

  module ClassMethods
    def activate!(search_path)
      connection.schema_search_path = search_path
      Rails.logger.warn "Switched schema_search_path to #{connection.schema_search_path}"
    end


    def current_search_path
      connection.schema_search_path
    end

    def use(data_namespace)
      old_namespace = current_search_path
      activate!(data_namespace)
      yield
    ensure
      activate!(old_namespace)
    end
  end
end
