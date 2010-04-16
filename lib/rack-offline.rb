require "rack/offline"

module Rails
  class Offline < Rack::Offline
    def self.call(env)
      @app ||= new
      @app.call(env)
    end

    def initialize(app = Rails.application, &block)
      config = app.config
      root = Rails.public_path

      block = cache_block unless block_given?

      opts = {
        :cache => config.cache_classes,
        :root => root,
        :logger => Rails.logger
      }

      super opts, &block
    end

  private

    def cache_block
      Proc.new do
        files = Dir[
          "#{root}/**/*.html"
          "#{root}/stylesheets/**/*.css",
          "#{root}/javascripts/**/*.js",
          "#{root}/images/**"]

        files.each do |file|
          cache file.relative_path_from(root)
        end

        cache *files
        network "/"
      end
    end

  end
end