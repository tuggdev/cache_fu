module ActsAsCached
  module Config
    extend self

    @@class_config = {}
    mattr_reader :class_config

    def valued_keys
      [ :store, :version, :pages, :per_page, :ttl, :finder, :cache_id, :find_by, :key_size ]
    end

    def setup(options)
      config = options['defaults']

      case options[Rails.env]
      when Hash   then config.update(options[Rails.env])
      when String then config[:disabled] = true
      end

      config.symbolize_keys!

      setup_benchmarking! if config[:benchmarking] && !config[:disabled]

      setup_cache_store! config
      config
    end

    def setup_benchmarking!
      ActiveSupport.on_load(:action_controller) do
        include ActsAsCached::MemcacheRuntime
      end
    end

    def setup_cache_store!(config)
      config[:store] =
        if config[:store].nil?
          setup_memcache config
        elsif config[:store].respond_to? :constantize
          config[:store].constantize.new
        else
          config[:store]
        end
    end

    def setup_memcache(config)
      config[:namespace] << "-#{Rails.env}"

      # if someone (e.g., interlock) already set up memcached, then
      # we need to stop here
      return CACHE if Object.const_defined?(:CACHE)

      silence_warnings do
        Object.const_set :CACHE, memcache_client(config)
        Object.const_set :SESSION_CACHE, memcache_client(config) if config[:session_servers]
      end

      CACHE.respond_to?(:servers=) ? (CACHE.servers = Array(config.delete(:servers))) : CACHE.instance_variable_set('@servers', Array(config.delete(:servers)))
      CACHE.instance_variable_get('@options')[:namespace] = config[:namespace] if CACHE.instance_variable_get('@options')

      SESSION_CACHE.servers = Array(config[:session_servers]) if config[:session_servers]

      setup_session_store   if config[:sessions]
      setup_fast_hash!      if config[:fast_hash]
      setup_fastest_hash!   if config[:fastest_hash]

      CACHE
    end

    def memcache_client(config)
      (config[:client] || "MemCache").classify.constantize.new(config)
    end

    def setup_session_store
      return # Set up session store like normal in config/application.rb
      
      ActionController::Base.session_store = :mem_cache_store
      cache = defined?(SESSION_CACHE) ? SESSION_CACHE : CACHE
      ActionController::Session::AbstractStore::DEFAULT_OPTIONS.update(
        :memcache_server => cache.servers,
        :readonly => cache.readonly?,
        :failover => cache.failover,
        :timeout => cache.timeout,
        :logger => cache.logger,
        :namespace => cache.namespace
      )
    end

    # break compatiblity with non-ruby memcache clients in exchange for speedup.
    # consistent across all platforms.
    def setup_fast_hash!
      def CACHE.hash_for(key)
        (0...key.length).inject(0) do |sum, i|
          sum + key[i]
        end
      end
    end

    # break compatiblity with non-ruby memcache clients in exchange for speedup.
    # NOT consistent across all platforms.  Object#hash gives different results
    # on different architectures.  only use if all your apps are running the
    # same arch.
    def setup_fastest_hash!
      def CACHE.hash_for(key) key.hash end
    end
  end
end
