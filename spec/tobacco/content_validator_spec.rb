require 'spec_helper'


describe Tobacco::ContentValidator do

  class Consumer
    def on_read_error(error)
    end
  end

  let(:consumer) { Consumer.new }
  let(:smoker) { Tobacco::Smoker.new(consumer) }

  subject { Tobacco::ContentValidator.new(smoker) }

  before do
    smoker.stub(:filepath).and_return('/path')
    Tobacco::Callback.instance.stub(:writer).and_return(consumer)
  end

  describe '#validate!' do
    context 'when validation passes' do
      let(:content) { 'Lorem ipsum' }

      before { smoker.content = content }

      it 'calls continue write' do
        smoker.should_receive(:continue_write)
        smoker.consumer.should_not_receive(:on_read_error)

        subject.validate!
      end
    end
  end

  describe '#validate!' do
    context 'when validation fails' do
      before { smoker.content = '' }

      it 'does not call continue write on' do
        smoker.should_not_receive(:continue_write)

        subject.validate!
      end

      it 'calls on_read_error' do
        consumer.should_receive(:on_read_error)

        subject.validate!
      end
    end
  end
end
