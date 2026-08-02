# frozen_string_literal: true

require 'spec_helper'
require 'timeout'

describe Plaintext::RtfHandler do

  subject { described_class.new }

  if described_class.available?
    it 'Should extract text from .rtf files' do
      file = File.new('spec/fixtures/files/text.rtf', 'r')

      expect(subject.text(file)).to eq "lorem ipsum fulltext find me!\n"
      expect(Plaintext::Resolver.new(file, 'application/rtf').text).to match /lorem ipsum fulltext find me!/
    end

    it 'Should only extract text up to given size limit' do
      file = File.new('spec/fixtures/files/text.rtf', 'r')
      expect(subject.text(file, max_size: 5)).to eq 'lorem'

      r = Plaintext::Resolver.new(file, 'application/rtf')
      r.max_plaintext_bytes = 5
      expect(r.text).to eq "lorem"
    end

    it 'Should return a utf8 encoded string' do
      file = File.new('spec/fixtures/files/text.rtf', 'r')
      expect(subject.text(file).encoding.name).to eq 'UTF-8'
    end

    it 'Should extract umlauts correctly into UTF-8' do
      file = File.new('spec/fixtures/files/text-with-umlaut.rtf', 'r')

      expect(subject.text(file))
        .to eq "lorem ipsum In der Küche hat es eine Kaffeemaschine, mañana habrá café\n"
      expect(Plaintext::Resolver.new(file, 'application/rtf').text)
        .to match /In der Küche hat es eine Kaffeemaschine, mañana habrá café/
    end

  else
    warn "#{described_class.name} could not be tested as external program is not available."
  end

  # not every unrtf build prepends the header we use as a marker to strip its
  # preamble, see the --quiet change in 0.3.4. Output without it is returned as
  # is, through a separate branch which real unrtf output never reaches.
  describe 'output without the unrtf header' do
    subject { passthrough_handler described_class }

    if File.executable?('/bin/cat')
      it 'Should keep non-ASCII characters intact' do
        file = File.new('spec/fixtures/files/text-with-umlaut-latin1.txt', 'r')

        expect(subject.text(file)).to match /In der Küche.*mañana habrá café/
        expect(subject.text(file, max_size: 4096)).to match /In der Küche.*mañana habrá café/
      end

      it 'Should only extract text up to given size limit' do
        file = File.new('spec/fixtures/files/text-with-umlaut-latin1.txt', 'r')

        # a limit longer than the header takes the concatenating branch
        expect(subject.text(file, max_size: 50))
          .to eq 'lorem ipsum In der Küche hat es eine Kaffeemaschin'
        expect(subject.text(file, max_size: 5)).to eq 'lorem'
      end
    else
      warn "#{described_class.name} could not be tested as /bin/cat is not available."
    end
  end

  describe 'output with the unrtf header but no end marker' do
    subject { passthrough_handler described_class }

    if File.executable?('/bin/cat')
      it 'Should stop at the end of the stream' do
        file = File.new('spec/fixtures/files/unrtf-output-without-end-marker.txt', 'r')

        expect(Timeout.timeout(10) { subject.text(file) }).to eq ''
      end
    else
      warn "#{described_class.name} could not be tested as /bin/cat is not available."
    end
  end
end
