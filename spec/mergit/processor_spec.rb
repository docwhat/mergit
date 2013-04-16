require 'spec_helper'
require 'mergit/processor'

describe Mergit::Processor do
  let(:search_path)  { [LIB_PATH] }
  let(:replacements)  { {} }

  describe "find_requirement" do
    subject { Mergit::Processor.new(search_path, replacements, :string => '') }

    context "with a known lib-file" do
      let(:lib_file) { File.expand_path('../../../lib/mergit.rb', __FILE__) }
      let(:lib_name) { File.basename(lib_file, '.rb') }

      it "should find mergit.rb" do
        subject.find_requirement(lib_name).should eq(lib_file)
      end
    end

    it "should raise an exception when it doesn't exist" do
      expect { subject.find_requirement('does-not-exist') }.
        to raise_error(Mergit::RequirementNotFound)
    end
  end

  describe "scan_file" do
    subject { Mergit::Processor.new(search_path, replacements, :string => '') }
    context "of an existing lib_file" do
      let(:lib_file) { File.expand_path('../../../lib/mergit.rb', __FILE__) }
      let(:lib_name) { File.basename(lib_file, '.rb') }

      it "should append the contents of lib_file" do

      end
    end
  end

end
