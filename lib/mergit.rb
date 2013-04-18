# coding: utf-8
require 'mergit/version'
require 'mergit/processor'
require 'mergit/errors'

# A class for merging in `require`ments.
class Mergit
  # List of attributes accepted by {Mergit}, and the default values.
  #
  # @return [Hash]
  ATTRIBUTES = {
    :search_path => [Dir.pwd],
    :replacements => {},
  }.freeze

  ATTRIBUTES.each_key do |attr|
    attr_accessor attr
  end

  # Create a new mergit instance.
  #
  # @param [Hash] options See {ATTRIBUTES} for the list of options you can pass in.
  def initialize options=nil
    final_options = options ? ATTRIBUTES.merge(options) : ATTRIBUTES

    ATTRIBUTES.each_key do |attr|
      instance_variable_set("@#{attr}", final_options[attr])
    end
  end

  # Merge a file
  #
  # @param [Pathname, String] filename The name of the file to merge.
  # @return [String] The merged file.
  def process_file filename
    if File.file? filename
      create_file_processor(filename).output
    else
      raise MergitError.new "No such file: #{filename}"
    end
  end

  # Merge a string
  #
  # @param [String] string The text that should be merged.
  # @return [String] The merged output.
  def process string
    create_string_processor(string).output
  end

  # add file to visited list
  # scan file
  # for all requires, process files

  private

  # Helper to create a string processor
  #
  # @param [String] string The string to merge.
  # @return [Processor]
  # @!visibility private
  def create_string_processor string
    Processor.new(search_path, replacements, :string => string)
  end

  # Helper to create a file processor
  #
  # @param [Pathname, String] filename The file to process
  # @return [Processor]
  # @!visibility private
  def create_file_processor filename
    Processor.new(search_path, replacements, :filename => filename)
  end
end
