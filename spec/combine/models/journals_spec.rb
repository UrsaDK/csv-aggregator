# frozen_string_literal: true

describe Combine::Models::Journals do
  let(:stores) { { journals: '/p/a' } }
  let(:datasource) { instance_double(Combine::Datasources::Csv) }
  let(:all_journals) do
    [
      { 'ISSN' => 1, 'Title' => 'One' },
      { 'ISSN' => 2, 'Title' => 'Two' }
    ]
  end

  before do
    allow(Combine::Config).to receive(:[]).and_return(stores)
    allow(datasource).to receive(:formatter=)
    allow(datasource).to receive(:fetch).and_return(all_journals)
    allow(Combine::Datasources::Csv).to receive(:new).and_return(datasource)
  end

  describe 'responds to' do
    subject { described_class }
    it { is_expected.to respond_to :all }
  end

  describe '::all' do
    subject { described_class.tap(&:all) }
    it { is_expected.to have_attributes(all: all_journals) }
  end

  describe '::find_by_issn' do
    subject { described_class.find_by_issn(2) }
    it { is_expected.to eq('ISSN' => 2, 'Title' => 'Two') }
  end
end

describe Combine::Models::Formatters::Journal do
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
