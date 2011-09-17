module ActsAsCached
  module Config
    extend self

    @@class_config = {}
    mattr_reader :class_config

    def valued_keys
      [:version, :pages, :per_page, :finder, :cache_id, :find_by, :key_size]
    end

    def setup(options)
      config = options['defaults']

      case options[Rails.env]
      when Hash   then config.update(options[Rails.env])
      when String then config[:disabled] = true
      end

      config.symbolize_keys!

      setup_benchmarking! if config[:benchmarking] && !config[:disabled]
      config
    end

    def setup_benchmarking!
      ActiveSupport.on_load(:action_controller) do
        include ActsAsCached::MemcacheRuntime
      end
    end
  end
end
