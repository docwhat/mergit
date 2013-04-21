require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'yard'
require 'mergit'

task :default => :spec

def merge_file infile, outfile
  mergit = Mergit.new(:search_path => ['lib'])
  File.open(outfile, 'w', 0755) do |f|
    f.write mergit.process_file(infile)
  end
end

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb', '**/*.md']
end

desc "Build a standalone version of mergit"
task :standalone => 'bin/mergit-standalone'

file 'bin/mergit-standalone' => ['bin/mergit', 'Rakefile'] + Dir['lib/**/*.rb'] do
  merge_file 'bin/mergit', 'bin/mergit-standalone'
end

task :build => :standalone
