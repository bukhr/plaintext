# frozen_string_literal: true

require 'spec_helper'

describe Plaintext::PlaintextHandler do

  subject { described_class.new }

  it 'Should extract text from .txt files' do
    file = File.new('spec/fixtures/files/text.txt', 'r')
    expect(subject.text(file)).to match /lorem/
    expect(Plaintext::Resolver.new(file, 'text/plain').text).to match /lorem ipsum/
  end

  it 'Should extract text from .csv files' do
    file = File.new('spec/fixtures/files/spreadsheet.csv', 'r')
    expect(subject.text(file)).to match /lorem/
    expect(Plaintext::Resolver.new(file, 'text/csv').text).to match /lorem/
  end

  it 'Should accept a path string as input' do
    file = 'spec/fixtures/files/text.txt'
    expect(subject.text(file)).to match /lorem/
    expect(Plaintext::Resolver.new(file, 'text/plain').text).to match /lorem ipsum/
  end

  it 'Should accept a pathname as input' do
    file = Pathname('spec/fixtures/files/text.txt')
    expect(subject.text(file)).to match /lorem/
    expect(Plaintext::Resolver.new(file, 'text/plain').text).to match /lorem ipsum/
  end

  it 'Should only extract text up to given size limit' do
    file = File.new('spec/fixtures/files/text.txt', 'r')
    expect(subject.text(file, max_size: 2)).to eq 'lo'

    r = Plaintext::Resolver.new(file, 'text/plain')
    r.max_plaintext_bytes = 3
    expect(r.text).to eq "lor"
  end

  # the size limit is applied to the raw byte stream, so it may well cut
  # through a multi byte character
  it 'Should only replace the character the size limit cuts in half' do
    file = File.new('spec/fixtures/files/text-with-umlaut.txt', 'r')

    # 57 bytes covers everything up to and including the first byte of the
    # 'ñ' in 'mañana'
    expect(subject.text(file, max_size: 57))
      .to eq 'lorem ipsum In der Küche hat es eine Kaffeemaschine, ma?'

    r = Plaintext::Resolver.new(file, 'text/plain')
    r.max_plaintext_bytes = 57
    expect(r.text).to eq 'lorem ipsum In der Küche hat es eine Kaffeemaschine, ma?'
  end

  it 'Should return a utf8 encoded string' do
    file = File.new('spec/fixtures/files/text.txt', 'r')
    expect(subject.text(file).encoding.name).to eq 'UTF-8'
  end


end
