# -*- encoding: utf-8 -*-
require File.expand_path('../lib/iqeo/configuration/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Gerard Fowley"]
  gem.email         = ["gerard.fowley@iqeo.net"]
  gem.description   = %q{A configuration DSL}
  gem.summary       = %q{A DSL for writing configuration files}
  gem.homepage      = "http://github.com/iqeo/iqeo-conf"
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "iqeo-conf"
  gem.require_paths = ["lib"]
  gem.version       = Iqeo::Configuration::VERSION
end
