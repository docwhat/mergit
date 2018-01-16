# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mergit/version'

Gem::Specification.new do |spec|
  spec.name          = "mergit"
  spec.version       = Mergit::VERSION
  spec.authors       = ["Christian Höltje"]
  spec.email         = ["docwhat@gerf.org"]
  spec.summary       = %q{Merge 'require'd files into one file.}
  spec.description   = %q{Ever wanted to merge all your 'require'd files into one file for easy distribution? Mergit is your friend!}
  spec.homepage      = "https://github.com/docwhat/mergit"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",                 "~> 1.3"
  spec.add_development_dependency "rake",                    "~> 10.0"
  spec.add_development_dependency "yard",                    "~> 0.8"
  spec.add_development_dependency "redcarpet",               "~> 2.2"
  spec.add_development_dependency "rspec",                   "~> 2.13"
  spec.add_development_dependency "coveralls",               "~> 0.6"
  spec.add_development_dependency "guard-rspec",             "~> 2.5"
  spec.add_development_dependency "guard-bundler",           "~> 1.0"
  spec.add_development_dependency "rb-inotify",              "~> 0.9"
  spec.add_development_dependency "rb-fsevent",              "~> 0.9"
  spec.add_development_dependency "growl",                   "~> 1.0"
  spec.add_development_dependency "libnotify",               "~> 0.8"
  spec.add_development_dependency "terminal-notifier-guard", "~> 1.5"
end
