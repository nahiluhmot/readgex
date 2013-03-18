# -*- encoding: utf-8 -*-
require File.expand_path('../lib/readgex/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Tom Hulihan"]
  gem.email         = ["hulihan.tom159@gmail.com"]
  gem.description   = %q{Readable Regular Expressions}
  gem.summary       = %q{Readable Regular Expressions} 
  gem.homepage      = "https://github.com/nahiluhmot/readgex"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "readgex"
  gem.require_paths = ["lib"]
  gem.version       = Readgex::VERSION
  gem.add_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'cane'
  gem.add_development_dependency 'jeweler'
  gem.add_development_dependency 'pry'
end

