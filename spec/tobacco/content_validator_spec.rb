require 'spec_helper'

describe Tobacco::ContentValidator do

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
          # Tobacco::Inhaler.stub(:new).and_return(inhaler)
          # subject.file_path_generator = filepath
        end

        it 'the callback is called on the smoker' do
          # subject.writer.should_receive(:on_read_error)

          # subject.read
        end

        it 'has the correct message on the error object' do
          # subject.read

          # error   = subject.writer.error
          # message = error.object.message

          # message.should match(/No error encountered/)
        end
      end
    end
  end
end
