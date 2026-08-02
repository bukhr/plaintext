# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'plaintext'
require 'byebug'

# A handler piping the file through /bin/cat unchanged, so that the stream
# handling shared by all external command handlers can be tested without
# depending on any of the extraction tools being installed.
def passthrough_handler(base = Plaintext::ExternalCommandHandler)
  Class.new(base) do
    def initialize
      @content_type = 'text/plain'
      @command = ['/bin/cat', Plaintext::ExternalCommandHandler::FILE_PLACEHOLDER]
    end
  end.new
end
