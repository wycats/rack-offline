module Rack
  class Offline
    class Config
      attr_reader :cached, :network, :fallback

      def initialize(root, &block)
        @cached = []
        @network = []
        @fallback = {}
        @root = root
        instance_eval(&block) if block_given?
      end

      def cache(*names)
        @cached.concat(names)
      end

      def network(*names)
        @network.concat(names)
      end

      def fallback(hash = {})
        @fallback.merge(hash)
      end
      
      def root
        @root
      end
    end
  end
end