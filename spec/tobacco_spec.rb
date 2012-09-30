require 'spec_helper'

shared_examples_for "it's configured" do
  before do
    Tobacco.configure do |config|
      config.published_host         = published_host
      config.base_path              = base_path
      config.content_method         = content_method
      config.content_url_method     = content_url_method
      config.output_filepath_method = output_filepath_method
    end
  end

  it 'sets the publish host' do
    Tobacco.published_host.should == published_host
  end

  it 'sets the base path' do
    Tobacco.base_path.should == base_path
  end

  it 'sets the content method' do
    Tobacco.content_method.should == content_method
  end

  it 'sets the content url method' do
    Tobacco.content_url_method.should == content_url_method
  end

  it 'sets the output filepath method' do
    Tobacco.output_filepath_method.should == output_filepath_method
  end
end


describe Tobacco do

  context 'configuration' do

    context 'has default values when config option not set' do
      let(:published_host)         { 'http://localhost:3000' }
      let(:base_path)              { '/tmp/published_content' }
      let(:content_method)         { :content }
      let(:content_url_method)     { :content_url }
      let(:output_filepath_method) { :output_filepath }

      it_behaves_like "it's configured"
    end

    context 'configuration options override defaults' do
      let(:published_host)         { 'http://localhost' }
      let(:base_path)              { 'pub_content' }
      let(:content_method)         { :data }
      let(:content_url_method)     { :url }
      let(:output_filepath_method) { :out_filepath }

      it_behaves_like "it's configured"
    end
  end
end

