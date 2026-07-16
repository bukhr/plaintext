# frozen_string_literal: true

module Plaintext
  class DocHandler < ExternalCommandHandler
    CONTENT_TYPES = [
        'application/vnd.ms-word',
        'application/msword'
    ]
    DEFAULT = [
        '/usr/bin/catdoc', '-dutf-8', '__FILE__'
    ]
    def initialize
      @content_types = CONTENT_TYPES
      @command = Plaintext::Configuration['catdoc'] || DEFAULT
      @stream_encoding = Plaintext::Configuration['catdoc_encoding']
    end
  end
end