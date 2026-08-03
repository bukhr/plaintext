# frozen_string_literal: true

module Plaintext
  module CodesetUtil
    def self.to_utf8(str, encoding)
      return str if str.nil?

      enc = encoding.blank? ? 'UTF-8' : encoding
      str.force_encoding(enc)
      if enc.upcase != 'UTF-8'
        str = str.encode('UTF-8', invalid: :replace,
                         undef: :replace, replace: '?')
      elsif !str.valid_encoding?
        # only replace the invalid byte sequences, leave the rest of the
        # string alone. Reading up to a byte limit routinely cuts through a
        # multi byte character at the very end of the string.
        str = str.scrub('?')
      end
      str
    end
  end
end