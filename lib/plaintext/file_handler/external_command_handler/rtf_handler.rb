# frozen_string_literal: true

module Plaintext
  class RtfHandler < ExternalCommandHandler
    DEFAULT = [
        '/usr/bin/unrtf', '--nopict', '--text', '__FILE__'
    ].freeze
    def initialize
      @content_type = 'application/rtf'
      @command = Plaintext::Configuration['unrtf'] || DEFAULT
    end

    private

    UNRTF_HEADER = "###  Translation from RTF performed by UnRTF"
    END_MARKER   = "-----------------\n"

    # unrtf has no switch to make it write UTF-8: its --text output is always
    # Latin-1, it ignores the locale, and it replaces anything it cannot map
    # into Latin-1 with a question mark itself.
    def output_encoding
      'ISO-8859-1'
    end

    def read(io, max_size = nil)
      if line = io.read(UNRTF_HEADER.length)
        string = if line.starts_with? UNRTF_HEADER
          io.gets while $_ != END_MARKER
          io.read max_size
        else
          if max_size.nil?
            line + io.read
          elsif max_size > UNRTF_HEADER.length
            line + io.read(max_size - UNRTF_HEADER.length)
          else
            line[0,max_size]
          end
        end
        Plaintext::CodesetUtil.to_utf8 string, output_encoding
      end
    end
  end
end
