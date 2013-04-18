# coding: utf-8
require 'mergit/version'
require 'mergit/processor'
require 'mergit/errors'

class Mergit
  ATTRIBUTES = {
    :search_path => [Dir.pwd],
    :replacements => {},
  }.freeze

  ATTRIBUTES.each_key do |attr|
    attr_accessor attr
  end

  def initialize options=nil
    final_options = options ? ATTRIBUTES.merge(options) : ATTRIBUTES

    ATTRIBUTES.each_key do |attr|
      instance_variable_set("@#{attr}", final_options[attr])
    end
  end

  def process_file filename
    if File.file? filename
      create_file_processor(filename).output
    else
      raise MergitError.new "No such file: #{filename}"
    end
  end

  def process string
    create_string_processor(string).output
  end

  # add file to visited list
  # scan file
  # for all requires, process files

  private

  def create_string_processor string
    Processor.new(search_path, replacements, :string => string)
  end

  def create_file_processor filename
    Processor.new(search_path, replacements, :filename => filename)
  end
end
