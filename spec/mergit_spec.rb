require 'spec_helper'
require 'mergit'

describe Mergit do
  it 'should have a version number' do
    Mergit::VERSION.should_not be_nil
  end

  context "with no initial paramaters" do
    its(:search_path)  { should eq([Dir.pwd]) }
    its(:replacements) { should eq({}) }
  end

  context "with initial parameters" do
    let(:search_path)  { [LIB_PATH] }
    let(:replacements) { { 'VERSION' => '1.2.3' } }
    subject do
      Mergit.new({
        :search_path => search_path,
        :replacements => replacements,
      })
    end

    its(:search_path)  { should eq(search_path) }
    its(:replacements) { should eq(replacements) }
  end

  describe "process" do
    let(:text) { "require 'something'" }
    let(:processor) { double(Mergit::Processor, :output => 'output-text') }
    before { subject.stub(:create_string_processor).and_return(processor) }
    after { subject.process(text) }

    it "should call create_string_processor" do
      subject.should_receive(:create_string_processor).with(text)
    end
  end

  describe "process_file" do
    context "with a bogus libname" do
      it "should raise MergitError" do
        expect { subject.process_file('totolly-bogus-filename') }.
          to raise_error(Mergit::MergitError)
      end
    end

    context "with a legit libname" do
      let(:libname) { File.join(LIB_PATH, 'mergit.rb') }
      let(:processor) { double(Mergit::Processor, :output => 'output-text') }
      before { subject.stub(:create_file_processor).and_return(processor) }
      after { subject.process_file(libname) }

      it "should call create_file_processor" do
        subject.should_receive(:create_file_processor).with(libname)
      end

    end

  end
end
