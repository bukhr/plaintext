# frozen_string_literal: true

require 'spec_helper'

describe Plaintext::XlsxHandler do

  subject { described_class.new }

  it 'Should extract text from .xlsx files' do
    file = File.new('spec/fixtures/files/spreadsheet.xlsx', 'r')

    expect(subject.text(file).split.join(' ')).to include('lorem ipsum')

    expect(Plaintext::Resolver.new(file, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet').text.split.join(' ')).to(
      include('lorem ipsum fulltext find me!')
    )
  end
end