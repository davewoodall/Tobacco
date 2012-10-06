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


### Methods in Writer Classes ###

**Optional**

If the Writer class will be providing its own content, say from manipulating data from a database, this is the method Tobacco will be calling to get that content.

It is not required otherwise.

Return a String

```ruby
def content
  # A string to be written to file
end
```

**Required**

The url that will be read for content is created based on the published_host and the string returned from this method.

The following example will produce a url of "http://localhost:3000/entertainment/videos/1"

Return a String

```ruby
def content_url
  '/entertainment/videos/1'
end
```


The ouput_filepath can return a string or an array of path options. All are joined with the base_path to create the full path the file location.

Return a String or Array

```ruby
def output_filepath
  [ 'public', 'videos', '1', 'index.html' ]

  # or

  'public/videos/1/index.html'
end
```


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
error    - The error that was raised. An error object that responds to message.
```


```ruby
def before_write(content)
  # manipulate content

  return content #=> using "return" to emphasize that this method must return the content to Tobacco for writing
end
```


## Public API ##

The first thing to call is generate_file_paths so that the content_url and output_filepath is available to Tobacco for reading and writing.

```ruby
generate_file_paths
```

When the read method is called, it will do three things.
  
  1. Set the reader to either the calling class,
      because it implemented the content method, or to an instance of Tobacco::Inhaler to prepare for reading.
  2. Read the content
  3. Verify content was read successfully.
      If not, the callback :on_read_error will be called with an instance of Tobacco::Error as described above.

```ruby
read
```

Write can be called after these first two or you can skip the read method if the content is provided directly. In either case, if the content is written successfully the :on_success callback is called. If not, the :on_write_error callback is called.

```ruby
write!
```

Example using all three methods

```ruby
writer = Tobacco::Smoker.new(self)
writer.generate_file_paths
writer.read
writer.write!
```

Example when setting the content directly. This takes the content as a string and writes it to file.

```ruby
writer = Tobacco::Smoker.new(self)
writer.generate_file_paths
writer.content = 'lorem ipsum'
writer.write!
```

###Usage###

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
      writer = Tobacco::Smoker.new(self)
      writer.generate_file_paths
      writer.read
      writer.write!
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
      writer = Tobacco::Smoker.new(self)
      writer.generate_file_paths
      writer.read
      writer.write!
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

## Final Thoughts ##

To avoid duplication, we wrap the callbacks and write! method in a helper module that is included in all the Writer classes. This makes the individual Writers very small and easy to maintain.

## Future Improvements ##

Make a backup of the file before attempting a new write. If something goes wrong with the write and an empty file is created, restore the original.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write tests
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
## Credits


![Factory Code Labs](http://i.imgur.com/yV4u1.png)

Tobacco is maintained by [Factory Code Labs](http://www.factorycodelabs.com).

## License

Tobacco is Copyright © 2012 Factory Code Labs. It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.

