# frozen_string_literal: true

require 'pathname'

module Plaintext
  class PdfUrlExtractor
    def initialize(file_path, command = nil)
      @file_path = Pathname(file_path).to_s
      @command = command || default_command
    end

    def extract
      return [] unless available?

      output = IO.popen([@command, '-url', @file_path], 'r', err: File::NULL) do |io|
        io.set_encoding('UTF-8')
        io.read
      end

      parse_urls(output.to_s)
    rescue StandardError
      []
    end

    def available?
      @command && File.executable?(@command)
    end

    private

    # pdfinfo -url (poppler >= 21.11.0) prints a table: Page  Type  URL
    def parse_urls(output)
      lines = output.lines.drop(1)
      urls = lines.map { |line| line.strip.split(/\s+/, 3)[2] }

      urls.compact.uniq
    end

    def default_command
      pdftotext_cmd = Plaintext::Configuration['pdftotext']&.first || '/usr/bin/pdftotext'

      # Determine pdfinfo path based on pdftotext path
      pdfinfo_cmd = pdftotext_cmd.gsub('pdftotext', 'pdfinfo')

      return pdfinfo_cmd if File.executable?(pdfinfo_cmd)

      # Fallback to system PATH
      pdfinfo_in_path = ENV['PATH'].split(File::PATH_SEPARATOR).map { |p| File.join(p, 'pdfinfo') }.find { |f| File.executable?(f) && !File.directory?(f) }
      pdfinfo_in_path || 'pdfinfo'
    end
  end
end
