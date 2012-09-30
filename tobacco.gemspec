# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tobacco/version'

Gem::Specification.new do |gem|
  gem.name          = "tobacco"
  gem.version       = Tobacco::VERSION
  gem.authors       = ["Craig Williams"]
  gem.email         = ["cwilliams.allancraig@gmail.com"]
  gem.description   = %q{Url content fetcher and file writer}
  gem.summary       = %q{File writer that can read from a url or take a string and write to file}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'vcr'
  gem.add_development_dependency 'fakeweb'
end
