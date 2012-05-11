#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new('spec')

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include "README.rdoc", "lib/**/*.rb"
  rdoc.rdoc_files.exclude "lib/**/hash_with_indifferent_access.rb"
  rdoc.options << "--all" << "--verbose"
end

require 'yard'
#require 'yard/rake/yardoc_task'
YARD::Rake::YardocTask.new do |yard|
  yard.files   = %w( lib/**/*.rb )
  yard.options = %w( --main README.md --exclude hash_with_indifferent_access.rb )
end

task :default => :spec
