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
      PgNamespace.drop_namespace(namespace)
    end

    it "returns the namespaces listed in the current schema_search_path" do
      subject = PgNamespace.create!(name: namespace)
      subject.connection.schema_search_path = namespace

      expect(PgNamespace.current_namespaces).to include subject
    end
  end
end

describe PgNamespace do

  describe '#migrate!' do

    it "should activate the namespace" do
      namespace = 'migrates'
      begin
        subject = PgNamespace.create!(name: namespace)
        expect(PgNamespace.current_namespace).to_not eql subject
        subject.migrate!
        expect(PgNamespace.current_namespace).to eql subject
      ensure
        PgNamespace.reset
        PgNamespace.drop_namespace(namespace)
      end
    end

    it "should run migrations in this namespace"

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
