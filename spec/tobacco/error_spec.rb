require 'spec_helper'
require 'tobacco'

shared_examples_for "attributes set" do
  it 'msg is set' do
    error.msg.should == msg
  end

  it 'filepath is set' do
    error.filepath.should == filepath
  end

  it 'content is set' do
    error.content.should == content
  end

  it 'object is an error object' do
    error.object.message.should == error_object.message
  end
end

describe Tobacco::Error do
  subject { Tobacco::Error }

  describe '#new' do
    context 'sets attributes during initialize' do
      let(:msg)          { 'Error Writing' }
      let(:filepath)     { '/users/somepath/index.html' }
      let(:content)      { '<h1>Page Title</h1>'}
      let(:error_object) { RuntimeError.new("Can't do that!") }

      let(:error) do 
        subject.new(
          msg: msg,
          filepath: filepath,
          content: content,
          object: error_object
        )
      end

      it_behaves_like "attributes set"
    end

    context 'allows setting attributes directly' do
      let(:msg)          { 'Error Writing' }
      let(:filepath)     { '/users/no_permissions_here/index.html' }
      let(:content)      { '<h1>Overdone</h1>'}
      let(:error_object) { Exception.new("I know this is crazy. Not sure what just happened. Try it again and the error may not happen... maybe") }
      let(:error)        { subject.new }

      before do
        error.msg      = msg
        error.filepath = filepath
        error.content  = content
        error.object   = error_object
      end

      it_behaves_like "attributes set"
    end
  end

  describe '#to_a' do
    context 'when destructuring using *splat' do
      let(:msg)          { 'Error Writing' }
      let(:filepath)     { '/users/somepath/index.html' }
      let(:content)      { '<h1>Page Title</h1>'}
      let(:error_object) { RuntimeError.new("Can't do that!") }

      let(:expected_array) { [ msg, filepath, content, error_object ] }

      let(:error) do 
        subject.new(
          msg: msg,
          filepath: filepath,
          content: content,
          object: error_object
        )
      end

      it 'sets the array of variables' do
        splatted = *error
        expected_array.should == splatted
      end
    end
  end
end
