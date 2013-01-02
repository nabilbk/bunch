# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bunch/version'

Gem::Specification.new do |gem|
  gem.name          = "bunch"
  gem.version       = Bunch::VERSION
  gem.authors       = ["Ryan Fitzgerald"]
  gem.email         = ["rfitz@academia.edu"]
  gem.summary       = %q{Directory-structure-based asset bundling.}
  gem.description   = gem.summary
  gem.homepage      = "https://github.com/academia-edu/bunch"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency     "mime-types",    "~> 1.19"

  gem.add_development_dependency "yard",          "~> 0.8.3"
  gem.add_development_dependency "minitest",      "~> 4.3.3"
  gem.add_development_dependency "mocha",         "~> 0.13.1"
  gem.add_development_dependency "rdiscount"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "guard"
  gem.add_development_dependency "guard-minitest"
  gem.add_development_dependency "pry"

  gem.add_development_dependency "coffee-script", "~> 2.2.0"
  gem.add_development_dependency "sass",          "~> 3.2.4"
  gem.add_development_dependency "ejs",           "~> 1.1.1"
end
