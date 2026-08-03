# frozen_string_literal: true

require 'spec_helper'

describe Plaintext::CodesetUtil do

  describe '.to_utf8' do
    it 'returns nil for nil' do
      expect(described_class.to_utf8(nil, 'UTF-8')).to be_nil
    end

    it 'returns an empty UTF-8 string for empty input' do
      result = described_class.to_utf8(''.dup, 'UTF-8')

      expect(result).to eq ''
      expect(result.encoding.name).to eq 'UTF-8'
    end

    it 'passes valid UTF-8 through' do
      expect(described_class.to_utf8('café'.dup, 'UTF-8')).to eq 'café'
    end

    it 'replaces only the invalid byte sequences of broken UTF-8' do
      expect(described_class.to_utf8("caf\xC3".dup, 'UTF-8')).to eq 'caf?'
    end

    it 'converts from the declared encoding' do
      expect(described_class.to_utf8("caf\xE9".dup, 'ISO-8859-1')).to eq 'café'
    end

    it 'assumes UTF-8 when no encoding is declared' do
      expect(described_class.to_utf8('café'.dup, nil)).to eq 'café'
      expect(described_class.to_utf8('café'.dup, '')).to eq 'café'
      expect(described_class.to_utf8('café'.dup, '  ')).to eq 'café'
    end

    it 'rejects an unknown encoding name whatever the length of the input' do
      expect { described_class.to_utf8(''.dup, 'bogus') }.to raise_error ArgumentError
      expect { described_class.to_utf8('café'.dup, 'bogus') }.to raise_error ArgumentError
    end
  end
end
