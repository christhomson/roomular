begin
  require 'vlad'

  # :app => nil since we don't want to use Mongrel
  Vlad.load(:app => nil, :scm => :git, :web => nil)
rescue LoadError
  # do nothing
end

Bundler.require :default