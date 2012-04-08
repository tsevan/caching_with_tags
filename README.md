# CachingWithTags

Support of tags for cache storages in Rails 3. Provides
massinvalidation of cached objects.

## Installation

Add this line to your application's Gemfile:

    gem 'caching_with_tags'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install caching_with_tags

## Usage Example
Here is an example of usage.
TODO: write a good guide.
    $ vitaly@way:path/to/project$ rails c
    :001 > Rails.cache.write 'foo', 'bar', :tags => ['tag1', 'tag2', 'tag3']
    :002 > Rails.cache.read 'foo'
    => "bar"
    :003 > Rails.cache.increment_tag 'tag1'
    :004 > Rails.cache.read 'foo'
    => nil
    :005 > Rails.cache.write 'foo', 'bar', :tags => ['tag1', 'tag2']
    :006 > Rails.cache.read 'foo'
    => "bar"
    :007 > Rails.cache.fetch 'foo', :tags => ['tag1', 'tag2'] { "bar2" }
    => "bar"
    :008 > Rails.cache.increment_tag 'tag1'
    => true
    :009 > Rails.cache.fetch 'foo', :tags => ['tag1', 'tag2'] { "bar2" }
    => "bar2"
