require 'spec_helper'

describe 'Helm (class methods)' do
  subject { Helm }
  describe '#find_database' do
    context "adapter == 'postgresql'" do
      let(:adapter) { 'postgresql' }

      it "should return a Postgresql::Database" do
        expect(
          subject.find_database(adapter: adapter,
                                database: 'helms_db_test')
        ).to be_a(Postgresql::Database)
      end
    end
  end
end
