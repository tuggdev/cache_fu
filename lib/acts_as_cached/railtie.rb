require 'cache_fu'
require 'rails'

module ActsAsCached
  class Railtie < Rails::Railtie
    railtie_name :cache_fu

    initializer :after_initialize do

      Object.send :include, ActsAsCached::Mixin

      unless File.exists?(config_file = Rails.root.join('config', 'memcached.yml'))
        error = "No config file found.  Make sure you used `script/plugin install' and have memcached.yml in your config directory."
        puts error
        logger.error error
        exit!
      end
      
      ActsAsCached.config = YAML.load(ERB.new(IO.read(config_file)).result)
    end

    rake_tasks do
      load 'tasks/memcached.rb'
    end
  end
end
