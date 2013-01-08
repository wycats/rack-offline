module Rack
  class Offline
    class Config
      def initialize(root, &block)
        @cache = []
        @network = []
        @fallback = {}
        @root = root
        instance_eval(&block) if block_given?
      end

      def cache(*names)
        options = names.last.is_a?(Pathname) ? {} : names.pop
        @cache.concat([{names: names, options: options}])
      end

      def cached_files
        @cache.inject([]){ |all_cache, cache| all_cache.concat(cache[:names]) }
      end

      def network(*names)
        @network.concat(names)
      end

      def fallback(hash = {})
        @fallback.merge!(hash)
      end
      
      def root
        @root
      end
    end
  end
end
