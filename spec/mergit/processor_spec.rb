require 'spec_helper'
require 'mergit/processor'

describe Mergit::Processor do
  let(:search_path)  { [LIB_PATH] }
  let(:replacements)  { {} }

  describe "find_requirement" do
    subject { Mergit::Processor.new(search_path, replacements, :string => '') }

    context "with a known lib-file" do
      let(:lib_file) { Pathname.new File.expand_path('../../../lib/mergit.rb', __FILE__) }
      let(:lib_name) { lib_file.basename '.rb' }

      it "should find mergit.rb" do
        subject.find_requirement(lib_name).should eq(lib_file)
      end
    end

    it "should return nil if it doesn't exist" do
      subject.find_requirement('does-not-exist').should be_nil
    end
  end

  describe "find_requirement!" do
    subject { Mergit::Processor.new(search_path, replacements, :string => '') }

    context "with a known lib-file" do
      let(:lib_file) { Pathname.new File.expand_path('../../../lib/mergit.rb', __FILE__) }
      let(:lib_name) { lib_file.basename '.rb' }

      it "should find mergit.rb" do
        subject.find_requirement!(lib_name).should eq(lib_file)
      end
    end

    it "should raise an exception when it doesn't exist" do
      expect { subject.find_requirement!('does-not-exist') }.
        to raise_error(Mergit::RequirementNotFound)
    end
  end

  describe "scan_file" do
    subject { Mergit::Processor.new(search_path, replacements, :string => '', :do_not_close => true) }
    context "of an existing lib_file" do
      let(:lib_file) { Pathname.new('../../../lib/mergit/version.rb').expand_path(__FILE__) }
      let(:relative_lib_file) { 'lib/mergit/version.rb' }
      let(:lib_name) { lib_file.basename '.rb' }

      context "then the output" do
        before { subject.scan_file(lib_file) }
        it "should start with the merget header" do
          subject.output.should =~ /\A### MERGIT: Start of '#{relative_lib_file}'$/
        end

        it "should end with the merget header" do
          subject.output.should =~ /^### MERGIT: End of '#{relative_lib_file}'\Z/
        end

        it "contain the contents of lib_file" do
          subject.output.should include(lib_file.read)
        end
      end
    end

    context "with a lib_file that has a requires" do
      let(:required_content) { Pathname.new('../../../lib/mergit/version.rb').expand_path(__FILE__).read }
      let(:lib_file) { Pathname.new('../../../lib/mergit.rb').expand_path(__FILE__) }
      subject { Mergit::Processor.new(search_path, replacements, :string => '', :do_not_close => true) }
      before { subject.scan_file(lib_file) }

      it "should contain a required file" do
        subject.output.should include(required_content)
      end
    end
  end

end
