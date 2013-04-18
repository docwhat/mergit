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

The command line tool, `mergit`, is pretty self-explanatory.

You specify the ruby file you want `require`s merged into on the command line (via standard in, if you specify `-`) and any library directories
you want `require`d from.

You can specify the `--lib` flag multiple times.

There is also a `--replace` flag that lets you specify a string or regular expression (a string surrounded by `/`) that should be replaced.

Example:

    bin/mergit --replace mouse=cat filename

This will replace all occurances of "mouse" with "cat".

You can specify the `--replace` flag multiple times.

Use the `--output` flag to send the resulting output to someplace other than stdout.

#### MERGIT directives

You can also cause any line to be skipped by adding a Mergit directive in a comment at the end of the line.

Example:

    raise "This won't be in the merged output." # MERGIT: skip

### Library API

Simple usage:

```
search_path = [ '/path/to/lib', '/path/to/other/lib' ]
mergit = Mergit.new(:search_path => search_path)

string_of_merged_file = mergit.process_file('/path/to/file')
# or
string_of_merged_string = mergit.process(some_string)

```

For more detailed information, see the [documentation](http://rubydoc.info/gems/mergit/frames).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
