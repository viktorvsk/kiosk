# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_pricelist/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_pricelist'
  spec.version       = ActivePricelist::VERSION
  spec.authors       = ['Viktor Ablebeam']
  spec.email         = ['ablebeam@gmail.com']
  spec.summary       = 'Unifies different formats of Suppliers pricelists'
  spec.description   = 'Parse all your Suppliers pricelists. Calculate Prices and InStock params according to their individual rules. Output as XML using XSLT templates.'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*', 'LICENSE.txt', 'Rakefile', 'README.md']
  spec.test_files = Dir['spec/**/*']

  spec.add_dependency 'activesupport', '~> 4.2'
  spec.add_dependency 'nokogiri', '~> 1.6'
  spec.add_dependency 'simple_xlsx_reader', '~> 1'
  spec.add_dependency 'roo', '~> 1'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'awesome_print', '~> 1.6'
end
