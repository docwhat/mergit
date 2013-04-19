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

    # All `require`d files will have 'MERGIT' start and end comments around them showing what file was included.
    #
    # The initial `:filename` or `:string` will not have 'MERGIT' comments.
    #
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
          Pathname.new(options[:filename]).open('r') { |fp| scan(fp.read) }
        elsif options.key?(:string)
          scan(options[:string])
        end
      ensure
        @output.close unless options[:do_not_close]
      end
    end

    # Finds a library using the {#search_path}
    #
    # @param [String, Pathname] filename The name of the library to look for.
    # @return [Nil, Pathname] Returns `nil` if it isn't found or a {http://rubydoc.info/stdlib/pathname/frames Pathname} if it is found.
    def find_requirement filename
      filename = Pathname.new filename
      @search_path.each do |directory|
        possible_path = directory + filename.dirname + "#{filename.basename('.rb')}.rb"
        return possible_path.realpath if possible_path.file?
      end
      nil
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
        scan_file($1) or emit(line)
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
    # If the `filename` was already scanned, it'll do nothing and return `true`.
    #
    # If the `filename` doesn't exist in the {#search_path}, then it'll return `false`.
    #
    # @param [Pathname] filename The file to scan.
    # @return [FalseClass, TrueClass] Returns true if the file was emitted. Returns false if it cannot find the file in {#search_path}
    def scan_file filename
      filename_path = find_requirement(filename)
      return false if filename_path.nil?
      return true if @visited_files.include? filename_path

      @visited_files << filename_path
      emit "### MERGIT: Start of '#{filename}'"
      filename_path.readlines.each { |line| scan_line line }
      emit "### MERGIT: End of '#{filename}'"
      return true
    end

    ## Scans a string
    #
    # It splits a string up into individual lines via {#string_split} and
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
