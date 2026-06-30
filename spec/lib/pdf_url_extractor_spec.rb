# frozen_string_literal: true

require 'spec_helper'

describe Plaintext::PdfUrlExtractor do
  let(:file) { File.new('spec/fixtures/files/text-with-links.pdf', 'r') }
  subject { described_class.new(file) }

  if described_class.new('dummy').available?
    it 'should extract URLs from a PDF file' do
      urls = subject.extract
      expect(urls).to be_an(Array)
      expect(urls.size).to be > 0
      expect(urls).to include(match(/http/))
      expect(urls).to include(match(/mailto:/))
    end
  else
    warn "#{described_class.name} could not be tested as external program pdfinfo is not available."
  end
end