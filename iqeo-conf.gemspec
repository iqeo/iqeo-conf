# -*- encoding: utf-8 -*-
require File.expand_path('../lib/iqeo/configuration/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Gerard Fowley"]
  gem.email         = ["gerard.fowley@iqeo.net"]
  gem.description   = %q{A configuration DSL}
  gem.summary       = %q{A DSL for writing configuration files}
  gem.homepage      = "http://iqeo.github.com/iqeo-conf"
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
  gem.name          = "iqeo-conf"
  gem.require_paths = ["lib"]
  gem.version       = Iqeo::Configuration::VERSION

  gem.add_development_dependency "rake",      "~> 0.9.2"
  gem.add_development_dependency "rspec",     "~> 2.10.0"
  gem.add_development_dependency "yard",      "~> 0.8.1"
  gem.add_development_dependency "rdoc",      "~> 3.12.0"
  gem.add_development_dependency "redcarpet", "~> 2.1.1"

  #gem.add_dependency('blankslate', '~> 2.1.2.4')

end
