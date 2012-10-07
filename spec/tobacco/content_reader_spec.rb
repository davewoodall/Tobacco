require 'spec_helper'

describe Tobacco::ContentReader do
  before do
    Tobacco.configure do |config|
      config.published_host         = 'http://localhost:3000'
      config.base_path              = '/tmp/published_content'
      config.content_method         = :content
      config.content_url_method     = :content_url
      config.output_filepath_method = :output_filepath
    end
  end

  let(:consumer) { mock('consumer', content: 'Base content') }
  let(:smoker) { mock('smoker', file_path_generator: filepath, consumer: consumer, content: '') }
  let(:filepath) { mock('roller', content_url: '/video', output_filepath: '/file/path') }

  subject { Tobacco::ContentReader.new(smoker) }

  describe '#choose_reader' do
    context 'when consumer provides the content' do
      let(:consumer) { mock('consumer', content: 'Base content') }

      it 'uses the consumer for the content' do
        subject.choose_reader

        subject.reader.should == consumer
      end
    end

    context 'when smoker does not provide content' do
      let(:inhaler)  { mock('inhaler', read: 'reader method') }
      let(:filepath) { mock('roller', content_url: '/video') }

      before do
        smoker.consumer.unstub!(:content)
        Tobacco::Inhaler.stub(:new).and_return(inhaler)
      end

      it 'uses the smoker for the content' do
        subject.choose_reader
        subject.reader.should == inhaler
      end
    end
  end


  describe '#read_content' do
    context 'when content is read from the consumer' do
      let(:content) { 'Provided content' }

      before { smoker.consumer.stub(:content).and_return(content) }

      it 'should have the correct content' do
        subject.choose_reader
        subject.read_content

        subject.content.should == content
      end
    end

    context 'when content is read from url' do
      let(:content)  { 'Content from reading url' }
      let(:inhaler)  { mock('inhaler', read: content) }
      let(:filepath) { mock('roller', content_url: '/video', output_filepath: '/tmp/howdy.txt') }

      before do
        smoker.consumer.unstub!(:content)
        Tobacco::Inhaler.stub(:new).and_return(inhaler)
        smoker.stub(:file_path_generator).and_return(filepath)
      end

      it 'should have the correct content' do
        subject.choose_reader
        subject.read

        subject.content.should == content
      end
    end
  end

  describe 'modifies content' do
    let(:content) { '<h1>Summer Gear</h1>' }
    let(:modified_content) { '<h1>Winter Gear</h1>' }

    before do
      Tobacco::Callback.instance.writer = consumer
      smoker.consumer.stub(:content).and_return(content)
      smoker.consumer.stub(:before_write).and_return(modified_content)
    end

    it 'allows the consumer to modify content after reading' do
      subject.read

      subject.modified_content.should == modified_content
    end
  end

end  
