require 'spec_helper'
require 'tobacco'
require 'mock_configure'
require 'mock_smokers'

describe Tobacco::Roller do

  context 'paths' do
    before do
      Tobacco.configure do |config|
        config.published_host         = 'http://localhost:3000'
        config.base_path              = 'published_content'
        config.content_method         = :content
        config.content_url_method     = :content_url
        config.output_filepath_method = :output_filepath
      end
    end

    subject { Tobacco::Roller.new(smoker) }

    context 'when using default settings' do
      let(:smoker) { double('smoker') }
      let(:expected_output_filepath) { 'published_content/1/video/245' }

      describe '#output_filepath' do
        it 'builds a path when given array of options' do
          smoker.stub(:output_filepath) { [ '1', 'video', '245' ] }

          subject.output_filepath.should == expected_output_filepath
        end

        it 'builds a path when given a string' do
          smoker.stub(:output_filepath) { '1/video/245' }

          subject.output_filepath.should == expected_output_filepath
        end
      end

      describe '#content_url' do
        context 'when prepended with a forward slash' do
          let(:expected_content_url) { 'http://localhost:3000/publisher/video/245' }

          it 'builds a content url' do
            smoker.stub(:content_url) { '/publisher/video/245' }

            subject.content_url.should == expected_content_url
          end
        end

        context 'when not prepended with a forward slash' do
          let(:expected_content_url) { 'http://localhost:3000/publisher/video/245' }

          it 'builds a content url' do
            smoker.stub(:content_url) { 'publisher/video/245' }

            subject.content_url.should == expected_content_url
          end
        end
      end
    end


    context 'when overriding default settings' do
      let(:smoker) { double('smoker') }

      before do
        Tobacco.configure do |config|
          config.published_host         = 'http://localhost:5000'
          config.base_path              = 'pub_content'
          config.content_method         = :data
          config.content_url_method     = :url
          config.output_filepath_method = :fpath
        end
      end

      let(:smoker) { double('smoker') }
      let(:expected_output_filepath) { 'pub_content/1/video/245' }

      describe '#output_filepath' do
        it 'builds an ouput filepath' do
          smoker.stub(:fpath) { [ '1', 'video', '245' ] }

          subject.output_filepath.should == expected_output_filepath
        end
      end

      describe '#content_url' do
        context 'when prepended with a forward slash' do
          let(:expected_content_url) { 'http://localhost:5000/publisher/video/245' }

          it 'builds a content url' do
            smoker.stub(:url) { '/publisher/video/245' }

            subject.content_url.should == expected_content_url
          end
        end

        context 'when not prepended with a forward slash' do
          let(:expected_content_url) { 'http://localhost:5000/publisher/video/245' }

          it 'builds a content url' do
            smoker.stub(:url) { 'publisher/video/245' }

            subject.content_url.should == expected_content_url
          end
        end
      end
    end
  end
end
