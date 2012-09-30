require 'spec_helper'
require 'tobacco'

describe Tobacco::Smoker do
  let(:smoker) { mock('smoker') }

  subject { Tobacco::Smoker.new(smoker) }

  context '#write!' do
    context 'providing content directly' do

    end

    context 'providing content through the content method' do

    end

    context 'reading content from content_url' do

    end
  end

  describe '#generate_file_paths' do
    it 'sets the file_path_generator' do
      Tobacco::Roller.should_receive(:new).with(smoker)

      subject.generate_file_paths
    end
  end

  describe '#choose_reader' do
    context 'when smoker provides the content' do
      before { smoker.stub(:content) }

      it 'uses the smoker for the content' do
        subject.choose_reader
        subject.reader.should == smoker
      end
    end

    context 'when smoker does not provide content' do
      let(:inhaler)  { mock('inhaler', read: 'reader method') }
      let(:filepath) { mock('roller', content_url: '/video') }

      before do
        Tobacco::Inhaler.should_receive(:new).and_return(inhaler)
        subject.file_path_generator = filepath
      end

      it 'uses the smoker for the content' do
        subject.choose_reader
        subject.reader.should == inhaler
      end
    end
  end

  describe '#read_content' do
    context 'when content is read from the smoker' do
      let(:content) { 'Provided content' }

      before { smoker.stub(:content).and_return(content) }

      it 'should have the correct content' do
        subject.choose_reader
        subject.read_content

        subject.content.should == content
      end
    end

    context 'when content is read from url' do
      let(:content)  { 'Content from reading url' }
      let(:inhaler)  { mock('inhaler', read: content) }
      let(:filepath) { mock('roller', content_url: '/video') }

      before do
        Tobacco::Inhaler.should_receive(:new).and_return(inhaler)
        subject.file_path_generator = filepath
      end

      it 'should have the correct content' do
        subject.choose_reader
        subject.read_content

        subject.content.should == content
      end
    end
  end

  describe '#read' do
    context 'when content is empty' do
      class Writer
        attr_accessor :error
        def on_read_error(error)
          self.error = error
        end
      end

      describe '#on_read_error' do
        let(:inhaler)  { mock('inhaler', read: '') }
        let(:filepath) { mock('roller', content_url: '/video', filepath: '/file/path') }
        let(:smoker)   { Writer.new }

        before do
          Tobacco::Inhaler.should_receive(:new).and_return(inhaler)
          subject.file_path_generator = filepath
        end

        it 'an error is returned to the callback' do
          subject.smoker.should_receive(:on_read_error)

          subject.read
        end

        it 'has the correct message on the error object' do
          subject.read

          error   = subject.smoker.error
          message = error.object.message

          message.should match(/No error encountered/)
        end
      end
    end
  end
end
