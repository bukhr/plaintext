# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_support/all'
require 'plaintext'
require 'byebug'

pdftotext_path = ENV['PATH'].split(File::PATH_SEPARATOR).map { |p| File.join(p, 'pdftotext') }.find { |f| File.executable?(f) && !File.directory?(f) }
if pdftotext_path
  Plaintext::Configuration.config ||= {}
  Plaintext::Configuration.config['pdftotext'] = [pdftotext_path, '-enc', 'UTF-8', '__FILE__', '-']
end
