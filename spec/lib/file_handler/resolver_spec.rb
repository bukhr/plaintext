# frozen_string_literal: true

require 'spec_helper'

describe Plaintext::Resolver do
  subject(:resolver) do
    file = File.new('spec/fixtures/files/text.txt', 'r')
    described_class.new(file, 'text/plain')
  end
  let(:handler) { resolver.send(:find_handler) }


  # NOTA: Este test viene del upstream pero nosotros modificamos el resolver
  # por lo que no tiene sentido que lo pasemos. Modificamos su contenido con una
  # versión compatible al código actual.
  it 'squishes and strips the text returned by the handler' do
    allow(handler).to receive(:text).and_return("  hello \n \n world! ")

    expect(resolver.text).to eq("  hello \n \n world! ")
  end

  it 'returns nil if the handler returns nil' do
    allow(handler).to receive(:text).and_return(nil)

    expect(resolver.text).to be_nil
  end

  it 'can deal with frozen string returned by the handler' do
    # make the handler return a frozen string
    allow(handler).to receive(:text).and_wrap_original { |m, *args| m.call(*args).freeze }

    expect(resolver.text).to include(/lorem ipsum/)
  end
  it 'normalizes decomposed text without calling mb_chars' do
    text = +"Cafe\u0301"
    allow(handler).to receive(:text).and_return(text)
    expect(text).not_to receive(:mb_chars)

    expect(resolver.text).to eq("Caf\u00e9")
  end

  it 'limits bytes without returning a partial Unicode character' do
    allow(handler).to receive(:text).and_return("ab\u00e9\u{1f600}z")

    { 0 => '', 1 => 'a', 3 => 'ab', 4 => "ab\u00e9", 7 => "ab\u00e9", 8 => "ab\u00e9\u{1f600}" }.each do |limit, expected|
      resolver.max_plaintext_bytes = limit
      expect(resolver.text).to eq(expected)
      expect(resolver.text).to be_valid_encoding
    end
  end

  it 'rejects a negative byte limit' do
    allow(handler).to receive(:text).and_return('abc')
    resolver.max_plaintext_bytes = -1

    expect { resolver.text }.to raise_error(ArgumentError)
  end

  it 'treats extracted bytes as UTF-8 without mutating a frozen binary source' do
    text = "Cafe\u0301".b.freeze
    allow(handler).to receive(:text).and_return(text)

    expect(resolver.text).to eq("Caf\u00e9")
    expect(resolver.text.encoding).to eq(Encoding::UTF_8)
    expect(text.encoding).to eq(Encoding::BINARY)
  end

  it 'keeps a complete grapheme when a byte limit falls inside a joined emoji' do
    allow(handler).to receive(:text).and_return("ab\u{1f468}\u200d\u{1f469}\u200d\u{1f467}\u200d\u{1f466}")
    resolver.max_plaintext_bytes = 8

    expect(resolver.text).to eq('ab')
  end

end
