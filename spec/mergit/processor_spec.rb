require 'spec_helper'
require 'mergit/processor'

describe Mergit::Processor do
  let(:search_path)  { [EXAMPLE_DIR] }
  let(:replacements)  { {} }
  let(:do_not_close) { false }  # Setting this to true prevents the @output being closed (and preventing further calls of scan_*())
  let(:mergit_options) { { :string => '', :do_not_close => do_not_close } }
  subject { Mergit::Processor.new(search_path, replacements, mergit_options) }

  let(:no_requires_file) { EXAMPLE_DIR + 'no_requires.rb' }
  let(:has_requires_file) { EXAMPLE_DIR + 'has_requires.rb' }
  let(:relative_path_file) { EXAMPLE_DIR + 'relative' + 'path.rb' }

  describe "#new" do
    context "when passed a filename" do
      after { Mergit::Processor.new(search_path, replacements, :filename => no_requires_file) }

      it "should not add MERGIT comments" do
        Mergit::Processor.any_instance.should_not_receive(:emit).with(/MERGIT/)
      end
    end
  end

  describe "find_requirement" do
    let(:expected_filename) { has_requires_file }

    shared_examples "find requirement" do
      it "should return an absolute path" do
        subject.find_requirement(filename).should be_absolute
      end

      it "should return the expected Pathname" do
        subject.find_requirement(filename).should eq(expected_filename)
      end
    end

    context "with relative string filename" do
      let(:filename) { expected_filename.basename('.rb').to_s }
      it_behaves_like "find requirement"
    end

    context "with absolute string filename" do
      let(:filename) { expected_filename.to_s }
      it_behaves_like "find requirement"
    end

    context "with relative Pathname filename" do
      let(:filename) { expected_filename.basename('.rb') }
      it_behaves_like "find requirement"
    end

    context "with absolute Pathname filename" do
      let(:filename) { expected_filename }
      it_behaves_like "find requirement"
    end

    it "should return nil if it doesn't exist" do
      subject.find_requirement('does-not-exist').should be_nil
    end
  end

  describe "scan_file" do
    let(:do_not_close) { true }

    shared_examples "it emits a string that" do
      before { subject.scan_file(path) }

      it "should start with a MERGIT comment" do
        subject.output.should =~ /\A### MERGIT: Start of '#{path}'$/
      end

      it "should end with a MERGIT comment" do
        subject.output.should =~ /^### MERGIT: End of '#{path}'\Z/
      end
    end

    context "with an absolute path" do
      let(:path) { no_requires_file }
      it_behaves_like "it emits a string that"
    end

    context "with a relative path" do
      let(:path) { 'relative/path' }
      it_behaves_like "it emits a string that"
    end

    context "of an existing lib_file" do
      let(:lib_file) { no_requires_file }

      it "should call .scan_line multiple times" do
        subject.should_receive(:scan_line).exactly(3).times
        subject.scan_file(lib_file)
      end

      it "should return true" do
        subject.scan_file(lib_file).should be_true
      end

      it "contain the contents of lib_file" do
        subject.scan_file(lib_file)
        subject.output.should include(lib_file.read)
      end
    end

    it "should call .find_requirement with the filename" do
      subject.should_receive(:find_requirement).with('some_file_name')
      subject.scan_file('some_file_name')
    end

    context "with a filename that contains a requires" do
      let(:filename) { has_requires_file }
      let(:required_file) { no_requires_file }
      before { subject.scan_file(filename) }

      it "should contain the required file" do
        subject.output.should include(required_file.read)
      end
    end

    context "called a second time with the same filename" do
      before { subject.scan_file(no_requires_file) }

      it "should return true" do
        subject.scan_file(no_requires_file).should be_true
      end
    end

    context "with a filename that doesn't exist" do
      it "should return false" do
        subject.scan_file('file-does-not-exist').should be_false
      end
    end
  end

  describe "scan" do
    let(:do_not_close) { true }

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
    let(:do_not_close) { true }

    context "given a single requires" do
      let(:ruby_string) { "require 'no_requires'" }
      after { subject.scan_line ruby_string }

      it "should call scan_file()" do
        subject.should_receive(:scan_file).with('no_requires').once
      end

      context "that has a comment after it" do
        let(:ruby_string) { "require 'no_requires' # this is a comment" }

        it "should call scan_file()" do
          subject.should_receive(:scan_file).with('no_requires').once
        end
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
    let(:search_path) { [dir] }
    let(:do_not_close) { true }
    let(:dir) { EXAMPLE_DIR + 'loop' }

    it "should not go into an infinite loop" do
      subject.scan_file(dir + 'a.rb')
    end
  end

end
