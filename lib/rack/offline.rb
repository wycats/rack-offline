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
      end
    end

    def call(env)
      key = @key || Digest::SHA2.hexdigest(Time.now.to_s + Time.now.usec.to_s)

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

      [200, {"Content-Type" => "text/cache-manifest"}, body.join("\n")]
    end

  private

    def precache_key!
      hash = @config.cache.map do |item|
        Digest::SHA2.hexdigest(@root.join(item).read)
      end

      @key = Digest::SHA2.hexdigest(hash.join)
    end
  end
end
