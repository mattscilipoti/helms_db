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

require 'spec_helper'
describe 'Helm (class methods)' do
  subject { Helm }
  describe '#find_database' do
    context "adapter == 'postgresql'" do
      let(:adapter) { 'postgresql' }

      it "should return a Postgresql::Database" do
        expect(
          subject.find_database(adapter: adapter,
                                database: 'db_info_test')
        ).to be_a(Postgresql::Database)
      end
    end
  end
end
