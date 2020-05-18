# frozen_string_literal: true

describe Combine do
  let(:article) do
    {
      'DOI' => 'DOI',
      'Title' => 'Article Title',
      'ISSN' => 'ISSN'
    }
  end
  let(:author) do
    {
      'name' => 'Author Name',
      'articles' => ['DOI']
    }
  end
  let(:journal) do
    {
      'Title' => 'Journal Title',
      'ISSN' => 'ISSN'
    }
  end
  let(:datasource_csv) { instance_double('Combine::Datasources::Csv') }
  let(:datasource_data) do
    [
      {
        author: 'Author Name',
        doi: 'DOI',
        issn: 'ISSN',
        journal: 'Journal Title',
        title: 'Article Title'
      }
    ]
  end

  before do
    allow(Combine::Config).to receive(:[]).with(:output_format).and_return('csv')
    allow(datasource_csv).to receive(:data=)
    allow(Combine::Datasources::Csv).to receive(:new) { datasource_csv }
    allow(Combine::Models::Articles).to receive(:all).and_return([article])
    allow(Combine::Models::Authors).to \
      receive(:find_by_doi).with('DOI').and_return(author)
    allow(Combine::Models::Journals).to \
      receive(:find_by_issn).with('ISSN').and_return(journal)
  end

  describe 'class respond to' do
    subject { described_class }
    it { is_expected.to respond_to :journals_articles_authors }
  end

  describe '::journals_articles_authors' do
    subject(:combine) { described_class.journals_articles_authors }

    it 'initialises datasource writer' do
      combine
      expect(Combine::Datasources::Csv).to have_received(:new)
    end

    it 'creates combined output' do
      combine
      expect(datasource_csv).to have_received(:data=).with(datasource_data)
    end
  end
end
