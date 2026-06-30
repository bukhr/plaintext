# frozen_string_literal: true

module Plaintext
  class PdfHandler < ExternalCommandHandler
    DEFAULT = [
        '/usr/bin/pdftotext', '-enc', 'UTF-8', '__FILE__', '-'
    ].freeze

    def initialize
      @content_type = 'application/pdf'
      @command = Plaintext::Configuration['pdftotext'] || DEFAULT
    end

    def text(file, options = {})
      base_text = super(file, options)

      if options[:extract_urls]
        urls = Plaintext::PdfUrlExtractor.new(file).extract
        if urls.any?
          base_text += "\n\n" + urls.join("\n") + "\n"
        end
      end

      base_text
    end

    protected

    def utf8_stream?
      true
    end
  end
end