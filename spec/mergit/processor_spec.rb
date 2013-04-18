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

      it "should call .scan_line multiple times" do
        subject.should_receive(:scan_line).at_least(3).times
        subject.scan_file(lib_file)
      end

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

      it "should contain the required file" do
        subject.output.should include(required_content)
      end
    end
  end

  describe "scan" do
    subject { Mergit::Processor.new(search_path, replacements, :string => '', :do_not_close => true) }

    context "with a string" do
      let(:ruby_string) { "puts 'hello'\nrequire 'pathname'\n\nputs 'goodbye'\n" }

      context "should call .scan_line" do
        after { subject.scan(ruby_string) }

        it "multiple times" do
          subject.should_receive(:scan_line).at_least(3).times
        end

        it "with the contents of the contents of ruby_string" do
          ruby_string.split("\n").each do |line|
            subject.should_receive(:scan_line).with(line).once.ordered
          end
        end
      end

      context "then the output" do
        before { subject.scan(ruby_string) }

        it "contain the contents of lib_file" do
          subject.output.should include(ruby_string)
        end
      end
    end
  end

  describe "scan_line" do
    subject { Mergit::Processor.new(search_path, replacements, :string => '', :do_not_close => true) }

    context "given a single requires" do
      let(:ruby_string) { "require 'mergit/version'" }
      after { subject.scan_line ruby_string }

      it "should call scan_file()" do
        subject.should_receive(:scan_file).with(Pathname.new('../../../lib/mergit/version.rb').expand_path(__FILE__)).once
      end
    end

    context "given a line with MERGIT: skip" do
      let(:ruby_string) { "this should never be seen # MERGIT: skip " }
      after { subject.scan_line ruby_string }

      it "should not call emit" do
        subject.should_not_receive(:emit)
      end
    end

    context "with a replacements" do
      let(:replacements) do
        {
          'VERSION' => '1.2.3',
          /PROG\s*NAME/ => 'Awesome Program',
        }
      end

      context "matching on a string" do
        let(:ruby_string) { "puts 'The version is VERSION'" }
        let(:expected_string) { ruby_string.sub('VERSION', '1.2.3') }
        after { subject.scan_line ruby_string }

        it "should replace VERSION" do
          subject.should_receive(:emit).with(expected_string)
        end
      end

      context "matching on a regexp" do
        let(:ruby_string) { "puts 'The program is PROGNAME.'" }
        let(:expected_string) { ruby_string.sub('PROGNAME', 'Awesome Program') }
        after { subject.scan_line ruby_string }

        it "should replace PROGNAME" do
          subject.should_receive(:emit).with(expected_string)
        end
      end
    end
  end

  describe "string_split" do
    subject { Mergit::Processor.new(search_path, replacements, :string => '') }
    let(:example_parts) { [ 'one', '', 'two', 'three' ] }

    context "with unix newlines" do
      let(:example_string) { example_parts.join("\n") }
      it "should be correct" do
        subject.string_split(example_string).should eq(example_parts)
      end
    end

    context "with windows newlines" do
      let(:example_string) { example_parts.join("\r\n") }
      it "should be correct" do
        subject.string_split(example_string).should eq(example_parts)
      end
    end
  end

  context "with looping requires" do
    let(:dir) { EXAMPLE_DIR + 'loop' }
    subject do
      Mergit::Processor.new(
        [ dir ],
        {},
        :string => '',
        :do_not_close => true
      )
    end

    it "should not go into an infinite loop" do
      subject.scan_file(dir + 'a.rb')
    end
  end

end
