require_relative '../spec_helper'

#require_relative '../../app/models/pg_namespace'

describe PgNamespace, '(class methods)' do
  describe '.database_name' do
    it "returns the name of the current database" do
      expect(PgNamespace.database).to eq 'db_info_test'
    end
  end

  describe '.current_namespace' do
    it "errors if more than one namespace is in the schema_search_path" do
      stub(PgNamespace).current_namespaces { "public,another_namespace" }
      expect { PgNamespace.current_namespace }.to raise_error RuntimeError
    end
  end

  describe '.current_namespaces' do
    let(:namespace) { 'test_current' }
    after :all do
      PgNamespace.reset
      PgNamespace.drop_namespace(namespace)
    end

    it "returns the namespaces listed in the current schema_search_path" do
      subject = PgNamespace.create!(name: namespace)
      PgNamespace.connection.schema_search_path = namespace

      expect(PgNamespace.current_namespaces).to include subject
    end
  end
end


describe PgNamespace, '(w/o mocks)' do
  before :each do
    PgNamespace.create!(name: namespace)
    expect(PgNamespace.current_namespace).to_not eql subject
  end

  after :each do
    PgNamespace.reset
    PgNamespace.drop_namespace(namespace)
  end


  describe '#change_owner' do
    let(:namespace) { 'change_owner' }
    subject { PgNamespace.find(namespace) }

    it "should return self" do
      stub(PgNamespace.connection).execute(any_args) { true } # neuter execute
      expect(subject.change_owner('test')).to eq(subject)
    end

    it "should change the owner" do
      PgDatabase.new.create_role('new_owner')
      #db_owner = PgNamespace.connection_config[:username] || ENV['USER']
      expect(subject.owner).to_not eql('new_owner')
      subject.change_owner('new_owner')
      expect(subject.owner).to eql('new_owner')
    end
  end

  describe '#migrate!' do
    let(:namespace) { 'migrates' }
    subject { PgNamespace.find(namespace) }

    before :each do
      fake_class(ActiveRecord::Migrator) # neuter the migrator
    end

    it "should return self" do
      expect(subject.migrate!).to eq(subject)
    end

    it "should activate the namespace" do
      subject.migrate!
      expect(PgNamespace.current_namespace).to eql subject
    end

    it "should run migrations in this namespace" do
      subject.migrate!
      ActiveRecord::Migrator.should have_received.migrate(any_args)
    end

    it "should indicate a possible permission issue when Postgres indicates PG::InvalidSchemaName" do
      # fix the message, then fix the bug
      # PG::InvalidSchemaName: ERROR:  no schema has been selected to create in
      #see: http://www.softr.li/blog/2012/07/25/postgresql-schema-owner-altered-during-dump-prevent-access-from-rails
      pending "this test should probably be much lower (at connection?  pg gem?)."

      #connection = PgNamespace.connection
      #mock(connection).execute(any_args) { raise PG::InvalidSchemaName }
      #err = -> { subject.migrate! }.must_raise PG::InvalidSchemaName
      #err.message.must_match /permission/
    end
  end
end
