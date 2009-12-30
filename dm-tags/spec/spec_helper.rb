require 'rubygems'

# Use local dm-core if running from a typical dev checkout.
lib = File.join('..', '..', 'dm-core', 'lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib)
require 'dm-core'

# Use local dm-validations if running from a typical dev checkout.
lib = File.join('..', 'dm-validations', 'lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib)
require 'dm-validations'

# Support running specs with 'rake spec' and 'spec'
$LOAD_PATH.unshift('lib') unless $LOAD_PATH.include?('lib')

require 'dm-tags'

def load_driver(name, default_uri)
  return false if ENV['ADAPTER'] != name.to_s

  begin
    DataMapper.setup(name, ENV["#{name.to_s.upcase}_SPEC_URI"] || default_uri)
    DataMapper::Repository.adapters[:default] =  DataMapper::Repository.adapters[name]
    true
  rescue LoadError => e
    warn "Could not load do_#{name}: #{e}"
    false
  end
end

ENV['ADAPTER'] ||= 'sqlite3'

HAS_SQLITE3  = load_driver(:sqlite3,  'sqlite3::memory:')
HAS_MYSQL    = load_driver(:mysql,    'mysql://localhost/dm_core_test')
HAS_POSTGRES = load_driver(:postgres, 'postgres://postgres@localhost/dm_core_test')

Spec::Runner.configure do |config|
  config.before do
    Object.send(:remove_const, :TaggedModel) if defined?(TaggedModel)
    class ::TaggedModel
      include DataMapper::Resource

      property :id, Serial

      has_tags_on :skills, :interests, :tags
    end

    Object.send(:remove_const, :AnotherTaggedModel) if defined?(AnotherTaggedModel)
    class ::AnotherTaggedModel
      include DataMapper::Resource

      property :id, Serial

      has_tags_on :skills, :pets
    end

    Object.send(:remove_const, :DefaultTaggedModel) if defined?(DefaultTaggedModel)
    class ::DefaultTaggedModel
      include DataMapper::Resource

      property :id, Serial

      has_tags
    end

    Object.send(:remove_const, :UntaggedModel) if defined?(UntaggedModel)
    class ::UntaggedModel
      include DataMapper::Resource

      property :id, Serial
    end

    DataMapper.auto_migrate!
  end
end
