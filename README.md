# Tobacco [![Build Status](https://secure.travis-ci.org/CraigWilliams/Tobacco.png)](http://travis-ci.org/CraigWilliams/Tobacco)


Tobacco is a convenience wrapper around fetching content from a url or using the content supplied to it, verifying that content was received, creating a directory structure where the file will live and finally writing the content to that file.

This procedure is mostly simple url reading and making directories and writing to a file. We deal with a system where many files are being written to a specific parent directory and urls are formed using a pre-determined host and structure. The implementation details are consistent and to avoid duplication in our code, we extract the things that don't change from the things that do.

## Example

At Factory Code Labs, we work on a system for which we must deploy static HTML files. [Mike Pack](http://github.com/MikePack) has written a concurrency gem named [Pipes](http://github.com/MikePack/Pipes) that masterfully handles all the stages the publishing system must perform.

Tobacco is meant to complement the Writer classes that utilize Pipes. With a few configuration settings and two or three methods added to a writer class, Tobacco will handle the rest.

## Installation

Add this line to your application's Gemfile:

    gem 'tobacco'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tobacco

## Usage

Tobacco is very simple to use.


##Configuration##

First add a configuration file. In Rails for example, this can live in 'config/initializers/tobacco.rb'

```ruby
Tobacco.configure do |config|
  config.published_host         = Rails.env.development? ? 'http://localhost:3000' : 'http://localhost'
  config.base_path              = File.join(Rails.root, 'published_content', Rails.env)

  config.content_method         = :content
  config.content_url_method     = :content_url
  config.output_filepath_method = :output_filepath
end
```


**Default Values**

These are the setting that come default with Tobacco.

```ruby
  base_path              = '/tmp/published_content'
  published_host         = 'http://localhost:3000'
  content_method         = :content
  content_url_method     = :content_url
  output_filepath_method = :output_filepath
```

**Configuration Options**

```ruby
published_host
```

published_host will be used to form the host part of the url before reading a web pages' content.

```ruby
base_path
```

base_path is the base folder where all other folders and files will live when publishing files.
All file writing paths generated will be appended to the base_path.


### Required Methods in Writer Classes ###

```ruby
content_method
```

If the Writer class will be providing its own content, say from manipulating data from a database, this is the method Tobacco will be calling to get that content.

It is not required otherwise.

```ruby
content_url_method
```

The url that will be read for content is created based on the published_host and the string returned from this method.

ex.

```ruby
def content_url
  '/entertainment/videos/1'
end
```

Will produce a url of "http://localhost:3000/entertainment/videos/1"


```ruby
output_filepath_method
```

The ouput_filepath can return a string or an array of path options. All are joined with the base_path to create the full path the file location.


## Hook Methods ##

There are four (4) hook methods you can tie into during the reading and writing process. Three are for handling errors and one is for manipulating the content before it is written.

Be default, there are no 

```ruby
def on_success(content)
  # code to execute after content writen to file
end
```

```ruby
def on_read_error(error)
  # handle
end
```

```ruby
def on_write_error(error)
  # handle
end
```

The error is a Tobacco::Error object with the following attributes:

```ruby
msg      - A short description of the error
content  - The content or lack of content
filepath - The output path where the content was to be written
error    - The error that was raised
```


```ruby
def before_write(content)
  # manipulate content

  return content #=> using "return" to emphasize that this method must return the content to Tobacco for writing
end
```


## Public API ##

```ruby
generate_file_paths
```

```ruby
read
```

```ruby
write!
```

###Class Usage###

There are only three methods to add to your class that Tobacco needs to do its work and
only two of those are required. The third method allows your class to provide its own
content to be written to file. In many cases, the content being written to file is taken from
a database or other source and formatted by the class itself. Tobacco will simple take the 
provided content and write it to file for you.

Here is an example class using all three methods.

```ruby
module Writers
  class HTMLWriter
    def write!
      Tobacco::Smoker.new(self).write!
    end

    # If this method is present, Tobacco will use it instead of the content_url method.
    def content
      'Content to write to file'
    end

    def content_url
      '/vehicles/1/index.html'
    end

    def output_filepath
      [ 'vehicles', vehicle.model, vehicle.id, 'index.html']
    end
  end
end
```


This example includes the callback methods

```ruby
module Writers
  class HTMLWriter
    def write!
      Tobacco::Smoker.new(self).write!
    end

    # If this method is present, Tobacco will use it instead of the content_url method.
    def content
      'Content to write to file'
    end

    def content_url
      '/vehicles/1/index.html'
    end

    def output_filepath
      [ 'vehicles', vehicle.model, vehicle.id, 'index.html']
    end

    #--------------------------------------
    # Callbacks
    #--------------------------------------
    def on_success(content)
      # Send email notfications
    end

    def on_read_error(error)
      # code to handle missing content
    end

    def on_write_error(error)
      # code to handle write error
    end

    def before_write(content)
      # code to manipulate the content

      return content #=> using "return" to emphasize that this method must return the content to Tobacco for writing
    end
  end
end
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write tests
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
