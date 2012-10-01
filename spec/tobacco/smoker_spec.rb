require 'spec_helper'
require 'tobacco'


describe Tobacco::Smoker do
  before do
    Tobacco.configure do |config|
      config.published_host         = 'http://localhost:3000'
      config.base_path              = '/tmp/published_content'
      config.content_method         = :content
      config.content_url_method     = :content_url
      config.output_filepath_method = :output_filepath
    end
  end

  let(:smoker) { mock('smoker') }

  subject { Tobacco::Smoker.new(smoker) }

  context '#write!' do

    context 'when content is empty' do
      let(:inhaler)  { mock('inhaler', read: '') }
      let(:filepath) { mock('roller', content_url: '/video', output_filepath: '/user') }

      before do
        Tobacco::Inhaler.stub(:new).and_return(inhaler)
        subject.file_path_generator = filepath
      end

      it 'does not attempt a write' do
        Tobacco::Exhaler.should_not_receive(:new)

        subject.read
        subject.write!
      end
    end

    context 'content' do
      let(:content) { 'Directly set content' }
      let(:exhaler) { mock('exhaler', write!: true) }
      let(:filepath) { mock('roller', content_url: '/video', output_filepath: '/desktop') }

      before do
        Tobacco::Exhaler.stub(:new).and_return(exhaler)
        subject.file_path_generator = filepath
      end

      context 'when providing content directly' do

        it 'allows setting content directly' do
          exhaler.should_receive(:write!)
          subject.content = content

          subject.write!
        end

        it 'callback :on_success is called' do
          smoker.should_receive(:before_write).with(content).and_return(content)
          smoker.should_receive(:on_success).with(content)
          subject.content = content

          subject.write!
        end
      end

      context 'when an error occurs during writing' do
        let(:error) { raise RuntimeError.new('File Permission Error') }

        before do
          subject.file_path_generator = filepath
          smoker.should_receive(:before_write).with(content).and_return(content)
          exhaler.should_receive(:write!).and_return { error }
        end

        it 'calls the callback :on_write_error' do
          smoker.should_receive(:on_write_error)
          subject.content = content

          subject.write!
        end
      end
    end
  end

  describe '#modify_content_before_writing' do
    let(:content) { '<h1>Summer Gear</h1>' }
    let(:modified_content) { '<h1>Winter Gear</h1>' }

    before do
      smoker.stub(:before_write).and_return(modified_content)
    end

    it 'allows the smoker to modify content before writing' do
      subject.content = content

      subject.modify_content_before_writing.should == modified_content
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
        Tobacco::Inhaler.stub(:new).and_return(inhaler)
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
        Tobacco::Inhaler.stub(:new).and_return(inhaler)
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
        let(:filepath) { mock('roller', content_url: '/video', output_filepath: '/file/path') }
        let(:smoker)   { Writer.new }

        before do
          Tobacco::Inhaler.stub(:new).and_return(inhaler)
          subject.file_path_generator = filepath
        end

        it 'the callback is called on the smoker' do
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
