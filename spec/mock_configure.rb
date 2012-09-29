Tobacco.configure do |config|
  config.published_host         = 'http://localhost:3000'
  config.base_path              = 'published_content'
  config.content_method         = :content
  config.content_url_method     = :content_url
  config.output_filepath_method = :output_filepath
end
