# coding: utf-8
require 'mergit/errors'
require 'pathname'
require 'stringio'

class Mergit
  # The class that actually does the merge processing.
  class Processor

    # @return {Array<Pathname>} A frozen array of {http://rubydoc.info/stdlib/pathname/frames Pathname}s
    attr_reader :search_path

    # @return {Hash} A frozen hash with the rules for replacements.
    attr_reader :replacements

    # @param [Array<Pathname, String>] search_path The list of directories to search.
    # @param [Hash] replacements A list of keywords to replace.
    # @param [Hash] options Either `:filename` or `:string` should be set.
    def initialize search_path, replacements, options
      @search_path = search_path.map{|p| Pathname.new p}.freeze
      @replacements = replacements.freeze
      @visited_files = []

      @output = StringIO.new
      begin
        if options.key?(:filename)
          scan_file(Pathname.new(options[:filename]).realpath)
        elsif options.key?(:string)
          scan(options[:string])
        end
      ensure
        @output.close unless options[:do_not_close]
      end
    end

    # Finds a library using the {#search_path}
    #
    # @param [String] lib_name The name of the library to look for.
    # @return [Nil, Pathname] Returns `nil` if it isn't found or a {http://rubydoc.info/stdlib/pathname/frames Pathname} if it is found.
    def find_requirement lib_name
      @search_path.each do |directory|
        possible_path = directory + "#{lib_name}.rb"
        return possible_path.realpath if possible_path.file?
      end
      nil
    end


    # Finds a library using the {#search_path}
    #
    # This is identical to {#find_requirement} except it raises {Mergit::RequirementNotFound} if
    # it fails to find the library.
    #
    # @raise [Mergit::RequirementNotFound] if it can't find the library.
    # @param (see #find_requirement)
    # @return [Pathname] Returns the {http://rubydoc.info/stdlib/pathname/frames Pathname} of the library.
    # @see #find_requirement
    def find_requirement! lib_name
      find_requirement(lib_name).tap do |retval|
        raise Mergit::RequirementNotFound.new("Unabled to find require'd file: #{lib_name}") if retval.nil?
      end
    end

    ## Scans a single line of the file.
    #
    # It looks for things that need to be changed, and {#emit}s the resulting
    # (changed) line.
    #
    # @param [String] line The line to parse
    # @return [Nil]
    def scan_line line
      line.chomp!
      if line =~ /#\s*MERGIT:\s*skip\s*$/
        nil # do nothing
      elsif line =~ /^\s*require\s+'([^']+)'/ or line =~ /^\s*require\s+"([^"]+)"/
        requirement = find_requirement($1)
        if requirement.nil?
          emit line
        else
          scan_file requirement
        end
      else
        replacements.each_key do |string_to_replace|
          line.gsub!(string_to_replace, replacements[string_to_replace])
        end
        emit line
      end
    end

    ## Scans an entire file
    #
    # It passes each line of the file to {#scan_line} for parsing.
    #
    # @param [Pathname] filename The file to scan.
    # @return [Nil]
    def scan_file filename
      relative_filename = if filename.relative?
                            filename
                          else
                            filename.relative_path_from(Pathname.pwd)
                          end
      if @visited_files.include? relative_filename
        return
      else
        @visited_files << relative_filename
      end
      emit "### MERGIT: Start of '#{relative_filename}'"
      filename.readlines.each { |line| scan_line line }
      emit "### MERGIT: End of '#{relative_filename}'"
    end

    ## Scans a string
    #
    # It splits a string up into individual line via {#string_split} and
    # passes them to {#scan_line}.
    #
    # @param [String] string The string to parse.
    # @return [Nil]
    def scan string
      string_split(string).each { |line| scan_line line }
    end

    ## Split a string into lines.
    #
    # @param [String] string The string to split into lines.
    # @return [Array<String>] The split up string.
    def string_split string
      string.split(/\n|\r\n/)
    end

    ## The resulting processed output.
    #
    # @return [String]
    def output
      @output.close unless @output.closed?
      @final_output ||= @output.string
    end

    ## Sends a string to the {#output}
    #
    # @param [String] string The string to send to {#output}.
    # @return [Nil]
    def emit string
      @output.puts string
    end
  end
end
