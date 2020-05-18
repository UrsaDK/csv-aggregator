# frozen_string_literal: true

module Combine
  class << self
    def journals_articles_authors
      klass = Combine::Config[:output_format].downcase.capitalize
      output = Combine::Datasources.const_get(klass).new
      output.data = jaa_build
      output.to_s
    end

    private

    def jaa_build
      Combine::Models::Articles.all.each_with_object([]) do |article, results|
        author = Combine::Models::Authors.find_by_doi(article[:doi])
        journal = Combine::Models::Journals.find_by_issn(article[:issn])
        results.push(jaa_row(journal, article, author))
      end
    end

    def jaa_row(journal, article, author)
      {
        doi: article[:doi],
        title: article[:title],
        author: author[:name],
        journal: journal[:title],
        issn: journal[:issn]
      }
    end
  end
end
