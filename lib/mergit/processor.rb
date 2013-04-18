require 'mergit/errors'
require 'pathname'
require 'stringio'

class Mergit
  class Processor
    def initialize search_path, replacements, options
      @search_path = search_path.map{|p| Pathname.new p}
      @replacements = replacements
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

    def find_requirement lib_name
      @search_path.each do |directory|
        possible_path = directory + "#{lib_name}.rb"
        return possible_path.realpath if possible_path.file?
      end
      nil
    end

    def find_requirement! lib_name
      find_requirement(lib_name).tap do |retval|
        raise Mergit::RequirementNotFound.new("Unabled to find require'd file: #{lib_name}") if retval.nil?
      end
    end

    def scan_line line
      line.chomp!
      if line =~ /^\s*require\s+'([^']+)'\s*$/ or line =~ /^\s*require\s+"([^"]+)"\s*$/
        requirement = find_requirement($1)
        if requirement.nil?
          emit line
        else
          scan_file requirement
        end
      else
        emit line
      end
    end

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

    def scan string
      string_split(string).each { |line| scan_line line }
    end

    def string_split string
      string.split(/\n|\r\n/)
    end

    def output
      @output.close unless @output.closed?
      @final_output ||= @output.string
    end

    def emit string
      @output.puts string
    end

  end
end
