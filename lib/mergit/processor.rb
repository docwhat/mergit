require 'mergit/errors'
require 'pathname'

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

    def scan_file filename
      relative_filename = if filename.relative?
                            filename
                          else
                            filename.relative_path_from(Pathname.pwd)
                          end
      puts "### MERGIT: Start of '#{relative_filename}'"
      filename.readlines.each do |line|
        line.chomp!
        if line =~ /^\s*require\s+'([^']+)'\s*$/ or line =~ /^\s*require\s+"([^"]+)"\s*$/
          requirement = find_requirement($1)
          if requirement.nil?
            puts line
          else
            scan_file requirement
          end
        else
          puts line
        end
      end
      puts "### MERGIT: End of '#{relative_filename}'"
    end

    def scan string

    end

    def output
      @output.string
    end

    private

    def puts string
      @output.puts string
    end

  end
end
