shared_examples_for "it's configured" do
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
