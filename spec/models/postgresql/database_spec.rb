require 'spec_helper'

describe Postgresql::Database do
  subject { Postgresql::Database.find(ActiveRecord::Base.connection_config[:database]) }

  describe '(defaults)' do
    it { should be_readonly }
    its(:commander) { should be_a(PgCommands) }
    its(:db_config) { should == ActiveRecord::Base.connection_config }
  end

  describe '.create_role' do
    it "should add a role" do
      new_role = subject.create_role('new_role')
      expect(subject.roles).to include(new_role)
    end
  end

  describe '.name' do
    its(:name) { should == subject.datname }
  end
end

describe 'Postgresql::Database (class methods)' do
  subject { Postgresql::Database }

  its(:primary_key) { should == 'datname' }
  its(:table_name) { should == 'pg_catalog.pg_database' }
end
