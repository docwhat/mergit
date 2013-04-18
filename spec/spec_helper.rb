LIB_PATH = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift LIB_PATH

EXAMPLE_DIR = File.expand_path("../examples", __FILE__)

if ENV['TRAVIS'] == 'true'
  require 'coveralls'
  Coveralls.wear!
else
  begin
    require 'simplecov'
    SimpleCov.start
  rescue LoadError
    puts "Not loading simplecov"
  end
end

def example_file name
  File.join(EXAMPLE_DIR, name)
end

def example_content name
  File.open(example_file name, 'r').read
end

# EOF
