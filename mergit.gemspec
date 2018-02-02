lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mergit/version'

Gem::Specification.new do |spec|
  spec.name          = 'mergit'
  spec.version       = Mergit::VERSION
  spec.authors       = ['Christian Höltje']
  spec.email         = ['docwhat@gerf.org']
  spec.summary       = "Merge 'require'd files into one file."
  spec.description   = "Ever wanted to merge all your 'require'd files into one file for easy distribution? Mergit is your friend!"
  spec.homepage      = 'https://github.com/docwhat/mergit'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '~> 2.3'

  spec.add_development_dependency 'bundler',                 '~> 1.16'
  spec.add_development_dependency 'coveralls',               '~> 0.6'
  spec.add_development_dependency 'rake',                    '~> 10.0'
  spec.add_development_dependency 'rspec',                   '< 2.99'

  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'yard'
end
