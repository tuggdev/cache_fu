require 'cache_fu'
require 'rails'

module ActsAsCached
  class Railtie < Rails::Railtie
    initializer 'cache_fu:extends' do
    end

    rake_tasks do
      load 'tasks/memcached.rb'
    end
  end
end
