# -*- encoding: utf-8 -*-
require File.expand_path('../lib/iqeo/configuration', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "iqeo-conf"
  gem.author        = "Gerard Fowley"
  gem.email         = "gerard.fowley@iqeo.net"
  gem.description   = "A configuration DSL"
  gem.summary       = "A DSL for writing configuration files"
  gem.homepage      = "http://github.com/iqeo/iqeo-conf"
  gem.license       = "GPL-3.0"
  gem.files         = `git ls-files`.split("\n")
  gem.metadata      = { "rubygems_mfa_required" => "true" }
  gem.version       = Iqeo::Configuration::VERSION
end
