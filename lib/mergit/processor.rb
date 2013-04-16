require 'mergit/errors'

class Mergit
  class Processor
    def initialize search_path, replacements, options
      @search_path = search_path
      @replacements = replacements
      @visited_files = []

      @output = StringIO.new
      begin
        if options.key?(:filename)
          scan_file(File.realpath(options[:filename]))
        elsif options.key?(:string)
          scan(options[:string])
        end
      ensure
        @output.close
      end
    end

    def find_requirement lib_name
      @search_path.each do |directory|
        possible_path = File.join(directory, "#{lib_name}.rb")
        return File.realpath(possible_path) if File.file?(possible_path)
      end
      raise Mergit::RequirementNotFound.new("Unabled to find require'd file: #{lib_name}")
    end

    def scan string

    end

    def output
      @output.string
    end

  end
end
