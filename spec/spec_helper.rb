LIB_PATH = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift LIB_PATH

require 'pathname'
EXAMPLE_DIR = Pathname.new("../examples").expand_path(__FILE__)

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

# EOF
