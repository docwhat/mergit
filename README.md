# Mergit

* [![Build Status](https://secure.travis-ci.org/docwhat/mergit.png)](http://travis-ci.org/docwhat/mergit)
* [![Dependencies](https://gemnasium.com/docwhat/mergit.png)](https://gemnasium.com/docwhat/mergit)
* [![Coverage Status](https://coveralls.io/repos/docwhat/mergit/badge.png?branch=master)](https://coveralls.io/r/docwhat/mergit)

Mergit is a way to merge a bunch of `require`d files into one file.

This is useful to distribute single-file ruby executables, such as administration scripts, simple tools, etc.  Yet allows you to break
files out for easy design, programming and testing.

## Limitations

Mergit uses simple text processing, therefore it can be tripped up.  Some known problems include:

* `require` statements nested in code instead of at outermost scope of a file.

## Installation

Add this line to your application's Gemfile:

    gem 'mergit'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mergit

## Usage

### Command Line Tool

TODO: Write usage instructions here

### Library API

TODO: Write API description here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
