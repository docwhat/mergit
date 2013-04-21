# Mergit

* [![Build Status](https://secure.travis-ci.org/docwhat/mergit.png)](http://travis-ci.org/docwhat/mergit)
* [![Dependencies](https://gemnasium.com/docwhat/mergit.png)](https://gemnasium.com/docwhat/mergit)
* [![Coverage Status](https://coveralls.io/repos/docwhat/mergit/badge.png?branch=master)](https://coveralls.io/r/docwhat/mergit)

Mergit is a way to merge a bunch of `require`d files into one file.

This allows you develop, design, and test your ruby script using normal ruby best practices (rspec, etc.) and then
distribute them as a single-file ruby script.

Some use cases include:

* Administration scripts
* Simple tools
* Programs that need to work on any ruby without installing gems

## My original use case

When I wrote the original mergit, my goal was to distribute development/build
scripts to a variety of systems.

These scripts had the following requirements:

1. The scripts needed to be easy to install.
    * Our developers hadn't had experience with Ruby yet.  This is before ruby
      1.9.2 was released!
    * We didn't have an in-house RPM server (which wouldn't help our Windows
      systems anyway).
2. The scripts needed minimal or no requirements.
    * Bundler and RVM were new and a pain to automatically install.
    * Not all systems had the (easy) root access needed to install required
      gems or build tools.
    * All the CentOS systems had Ruby (>= 1.8.7 by default)
    * All the Windows systems could easily get a version of Ruby (a quirk of
      our development/build environment).
    * We had a mechanism to get a reasonably current ruby for Solaris.
3. The scripts needed to work on Windows, Solaris, and CentOS.
4. I wanted to write the scripts with the best practices; unit tests,
one-class-per-file, SOLID design.
    * I needed the scripts to work reliably, so I needed good tests.
    * It was easier to work on if we followed SOLID design principles.

The scripts I wrote in the end could be installed on any development or build
system via a simple `curl` and only required *any* working ruby of version
1.8.7 or greater.

This was possible because all the `.rb` files were merged into single files, including the one gem I needed (the pure ruby `minitar`).

## Limitations

Mergit uses simple text processing, therefore it can be tripped up.  Some known problems include:

* `require` statements nested in code instead of at outermost scope of a file will expand in-place. This probably isn't what you want.
* The order `require`d files are pulled in may be different than ruby.
* The replacement feature is very brute force.  Be careful using it.

## Installation

Add this line to your application's Gemfile:

    gem 'mergit', '~> 1.1'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mergit

Note: Mergit uses [Semantic Versioning](http://semver.org/).

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

    search_path = [ '/path/to/lib', '/path/to/other/lib' ]
    mergit = Mergit.new(:search_path => search_path)

    string_of_merged_file = mergit.process_file('/path/to/file')
    # or
    string_of_merged_string = mergit.process(some_string)

For more detailed information, see the [documentation](http://rubydoc.info/gems/mergit/frames).

## Additional Notes

To use up less space, you can compress the resulting script with `gzexe`.

## Contributing

### Level 1 -- Apprentice

File an [issue](https://github.com/docwhat/mergit/issues).

Make sure it includes the steps needed to reproduce it as well as what you expected to happen.

### Level 2 -- Journeyman

1. [Fork it](https://help.github.com/articles/fork-a-repo)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Level 3 -- Master

Repeat Level 2 until I give you write access on github. :-)

