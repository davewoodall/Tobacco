# A convenience module to gain access to 
# configuration options
#
require 'open-uri'
require 'timeout'

module Tobacco
  @base_path              = '/tmp/published_content'
  @published_host         = 'http://localhost:3000'
  @content_method         = :content
  @content_url_method     = :content_url
  @output_filepath_method = :output_filepath

  class << self
    attr_accessor :base_path,
      :published_host,
      :content_method,
      :content_url_method,
      :output_filepath_method
  end

  def self.configure
    yield self
  end

  def self.log(msg)
    Rails.logger.info(msg)
  end
end

require 'tobacco/callback_null_object'
require 'tobacco/burnout.rb'
require 'tobacco/smoker'
require 'tobacco/roller'
require 'tobacco/inhaler'
require 'tobacco/exhaler'
require 'tobacco/error'
