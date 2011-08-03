require "rack/offline/config"
require "rack/offline/version"
require "digest/sha2"
require "logger"
require "pathname"
require 'uri'

module Rack
  class Offline
    def self.configure(*args, &block)
      new(*args, &block)
    end
    
    # interval in seconds used to compute the cache key when in uncached mode
    # which can be set by passing in options[:cache_interval]
    # note: setting it to 0 or a low value will change the cache key every request
    # which means the manifest will never successfully download
    # (since it gets downloaded again at the end)
    UNCACHED_KEY_INTERVAL = 10

    def initialize(options = {}, &block)
      @cache    = options[:cache]

      @logger   = options[:logger] || begin
        ::Logger.new(STDOUT).tap {|logger| logger.level = 1 }
      end

      @root     = Pathname.new(options[:root] || Dir.pwd)

      if block_given?
        @config = Rack::Offline::Config.new(@root, &block)
      end

      if @cache
        raise "In order to run Rack::Offline in cached mode, " \
              "you need to supply a root so Rack::Offline can " \
              "calculate a hash of the files." unless @root
        precache_key!
      else
        @cache_interval = (options[:cache_interval] || UNCACHED_KEY_INTERVAL).to_i
      end
    end

    def call(env)
      key = @key || uncached_key

      body = ["CACHE MANIFEST"]
      body << "# #{key}"
      @config.cache.each do |item|
        body << URI.escape(item.to_s)
      end

      unless @config.network.empty?
        body << "" << "NETWORK:"
        @config.network.each do |item|
          body << URI.escape(item.to_s)
        end
      end

      unless @config.fallback.empty?
        body << "" << "FALLBACK:"
        @config.fallback.each do |namespace, url|
          body << "#{namespace} #{URI.escape(url.to_s)}"
        end
      end

      @logger.debug body.join("\n")

      [200, {"Content-Type" => "text/cache-manifest"}, [body.join("\n")]]
    end

  private

    def precache_key!
      hash = @config.cache.map do |item|
        path = @root.join(item)
        Digest::SHA2.hexdigest(path.read) if ::File.file?(path)
      end

      @key = Digest::SHA2.hexdigest(hash.join)
    end
    
    def uncached_key
      now = Time.now.to_i - Time.now.to_i % @cache_interval
      Digest::SHA2.hexdigest(now.to_s)
    end
    
  end
end
