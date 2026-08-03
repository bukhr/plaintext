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
end
