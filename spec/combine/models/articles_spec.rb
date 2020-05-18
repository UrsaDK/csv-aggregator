# frozen_string_literal: true

describe Combine::Models::Articles do
  let(:stores) { { articles: '/p/a' } }
  let(:datasource) { instance_double(Combine::Datasources::Csv) }

  before do
    allow(Combine::Config).to receive(:[]).and_return(stores)
    allow(datasource).to receive(:formatter=)
    allow(datasource).to receive(:fetch).and_return('test-string')
    allow(Combine::Datasources::Csv).to receive(:new).and_return(datasource)
  end

  describe 'responds to' do
    subject { described_class }
    it { is_expected.to respond_to :all }
  end

  describe '::all' do
    subject { described_class.tap(&:all) }
    it { is_expected.to have_attributes(all: 'test-string') }
  end
end

describe Combine::Models::Formatters::Article do
  subject(:formatter) { described_class }

  describe 'responds to' do
    it { is_expected.to respond_to :issn }
    it { is_expected.to respond_to :ISSN }
  end

  describe '::issn' do
    it { expect(formatter.issn('1234-5678')).to eq('1234-5678') }
    it { expect(formatter.issn('12345678')).to eq('1234-5678') }
  end
end
