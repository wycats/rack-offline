require "rack/offline"

module Rails
  class Offline < ::Rack::Offline
    def self.call(env)
      @app ||= new
      @app.call(env)
    end

    def initialize(options = {}, app = Rails.application, &block)
      config = app.config
      root = config.paths.public.to_a.first

      block = cache_block(Pathname.new(root)) unless block_given?

      opts = {
        :cache => config.cache_classes,
        :root => root,
        :logger => Rails.logger
      }.merge(options)

      super opts, &block
    end

  private

    def cache_block(root)
      Proc.new do
        files = Dir[
          "#{root}/**/*.html",
          "#{root}/stylesheets/**/*.css",
          "#{root}/javascripts/**/*.js",
          "#{root}/images/**/*.*"]
        
        files.each do |file|
          cache Pathname.new(file).relative_path_from(root)
        end

        network "/"
      end
    end

  end
end