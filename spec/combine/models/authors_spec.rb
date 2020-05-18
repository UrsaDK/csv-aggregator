# frozen_string_literal: true

describe Combine::Models::Authors do
  let(:stores) { { authors: '/p/a' } }
  let(:datasource) { instance_double(Combine::Datasources::Json) }
  let(:all_authors) do
    [
      { 'name' => 'odd', 'articles' => %w[1 3] },
      { 'name' => 'even', 'articles' => %w[2 4] }
    ]
  end

  before do
    allow(Combine::Config).to receive(:[]).and_return(stores)
    allow(datasource).to receive(:formatter=)
    allow(datasource).to receive(:fetch).and_return(all_authors)
    allow(Combine::Datasources::Json).to receive(:new).and_return(datasource)
  end

  describe 'responds to' do
    subject { described_class }
    it { is_expected.to respond_to :all }
  end

  describe '::all' do
    subject { described_class.tap(&:all) }
    it { is_expected.to have_attributes(all: all_authors) }
  end

  describe '::find_by_doi' do
    subject { described_class.find_by_doi(3) }
    it { is_expected.to eq('name' => 'odd', 'articles' => %w[1 3]) }
  end
end

describe Combine::Models::Formatters::Author do
  subject(:formatter) { described_class }

  describe 'responds to' do
    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :articles }
  end

  describe '::name' do
    it { expect(formatter.name(1)).to eq('1') }
    it { expect(formatter.name('1')).to eq('1') }
    it { expect(formatter.name(' 1 ')).to eq('1') }
  end

  describe '::articles' do
    it { expect(formatter.articles(1)).to eq([1]) }
    it { expect(formatter.articles([1, 2])).to eq([1, 2]) }
  end
end
