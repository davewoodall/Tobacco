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

  let(:consumer) { mock('consumer') }

  subject { Tobacco::Smoker.new(consumer) }

  context '#write!' do
    let(:filepath) { mock('roller', content_url: '/video', output_filepath: '/tmp/tobacco.txt') }

    before do
      subject.file_path_generator = filepath
    end

    context 'when content is empty' do

      it 'does not attempt a write' do
        consumer.stub(:content).and_return('')
        Tobacco::Exhaler.should_not_receive(:new)

        subject.read
        subject.write!
      end
    end

    context 'content success' do
      let(:consumer) { mock('smoker') }
      subject { Tobacco::Smoker.new(consumer) }

      context 'when providing content directly' do
        let(:content) { 'Directly set content' }
        let(:exhaler) { mock('exhaler', write!: true) }
        let(:filepath) { mock('roller', content_url: '/video', output_filepath: '/tmp/tobacco.txt') }

        before do
          Tobacco::Exhaler.stub(:new).and_return(exhaler)
          subject.content = content
        end

        it 'uses the provided content' do
          exhaler.should_receive(:write!)
          subject.write!
        end

        it 'does not call the :before_write callback' do
          Tobacco::Callback.instance.should_not_receive(:notify).with(:before_write, content)
          subject.write!
        end

        it 'callback :on_success is called' do
          Tobacco::Callback.instance.writer.should_receive(:on_success).with(content)
          subject.write!
        end
      end
    end

    context 'content errors' do
      context 'when an error occurs during writing' do
        let(:filepath) { mock('roller', content_url: '/video', output_filepath: '/users/blah.txt') }

        it 'calls the callback :on_write_error' do
          Tobacco::Callback.instance.should_receive(:notify).once
          subject.content = 'Directly set content'

          subject.write!
        end
      end
    end
  end

  describe '#generate_file_paths' do
    before { consumer.stub(:output_filepath).and_return('/tmp/path.txt') }

    it 'sets the file_path_generator' do
      Tobacco::Roller.should_receive(:new).with(consumer)

      subject.generate_file_paths
    end
  end
end
