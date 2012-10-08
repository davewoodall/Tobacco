# A convenience module to gain access to 
# configuration options
#
require 'open-uri'

module Tobacco

  # Default options in the event no configuration
  # file is created
  #
  @base_path              = '/tmp/published_content'
  @published_host         = 'http://localhost:3000'
  @content_method         = :content
  @content_url_method     = :content_url
  @output_filepath_method = :output_filepath
  @logging                = false

  class << self
    attr_accessor :base_path,
      :published_host,
      :content_method,
      :content_url_method,
      :output_filepath_method,
      :logging
  end

  def self.configure
    yield self
  end

  def self.log(msg)
    return unless logging

    log_msg =  "\n*******************************************\n"
    log_msg += "Tobacco::Log: #{msg}\n"
    log_msg += "*******************************************\n"

    if defined? Rails
      Rails.logger.info(log_msg)
    else
      puts log_msg
    end
  end
end

require 'tobacco/burnout.rb'
require 'tobacco/smoker'
require 'tobacco/roller'
require 'tobacco/inhaler'
require 'tobacco/exhaler'
require 'tobacco/error'
require 'tobacco/safety_net'
require 'tobacco/content_validator'
require 'tobacco/content_reader'
require 'tobacco/callback'

