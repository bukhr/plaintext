# frozen_string_literal: true

require 'spec_helper'

describe Plaintext::ExternalCommandHandler do
  let(:handler_class) do
    Class.new(described_class) do
      def initialize
        @content_type = 'text/plain'
        @command = ['/bin/cat', Plaintext::ExternalCommandHandler::FILE_PLACEHOLDER]
      end
    end
  end
  subject(:handler) { handler_class.new }

  if File.executable?('/bin/cat')
    it 'replaces non-ASCII bytes with question marks by default' do
      text = handler.text('spec/fixtures/files/text-with-umlaut.txt')

      expect(text).to include 'K??che'
      expect(text).to include 'ma??ana habr?? caf??'
    end

    it 'passes the stream through when the command output is declared as UTF-8' do
      handler.stream_encoding = 'UTF-8'
      text = handler.text('spec/fixtures/files/text-with-umlaut.txt')

      expect(text).to include 'Küche'
      expect(text).to include 'mañana habrá café'
    end

    it 'converts the declared stream encoding to UTF-8' do
      handler.stream_encoding = 'ISO-8859-1'
      text = handler.text('spec/fixtures/files/text-with-umlaut-latin1.txt')

      expect(text).to include 'Küche'
      expect(text).to include 'mañana habrá café'
    end
  else
    warn "#{described_class.name} could not be tested as /bin/cat is not available."
  end

  describe 'output encoding configuration' do
    after { Plaintext::Configuration.load }

    it 'reads the output encoding of each command from the configuration' do
      Plaintext::Configuration.load('catdoc_encoding: UTF-8')

      expect(Plaintext::DocHandler.new.stream_encoding).to eq 'UTF-8'
    end

    it 'defaults to the previous behavior when not configured' do
      Plaintext::Configuration.load('')

      expect(Plaintext::DocHandler.new.stream_encoding).to eq 'ASCII-8BIT'
      expect(Plaintext::PdfHandler.new.stream_encoding).to eq 'UTF-8'
    end
  end
end
