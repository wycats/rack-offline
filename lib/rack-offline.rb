require "rack/offline"

module Rails
  class Offline < ::Rack::Offline
    def self.call(env)
      @app ||= new
      @app.call(env)
    end

    def initialize(options = {}, app = Rails.application, &block)
      config = app.config
      root   = config.paths['public'].first
      block  = cache_block(Pathname.new(root)) unless block_given?

      opts = {
        :cache  => config.cache_classes,
        :root   => root,
        :logger => Rails.logger
      }.merge(options)

      super(opts, &block)
    end

  private

    def cache_block(root)
      Proc.new do
        if Rails.version >= "3.1"
          if Rails.configuration.assets.enabled
            files = Dir[
              "#{root}/**/*.html",
              "#{root}/#{Rails.configuration.assets.prefix}/**/*.{js,css,jpg,png,gif}"]
          else
            files = Rails.application.assets.each_logical_path(Rails.configuration.assets.precompile).map do |fn|
              "#{root}/#{Rails.configuration.assets.prefix}/#{fn}"
            end
          end
        else
          files = Dir[
            "#{root}/**/*.html",
            "#{root}/stylesheets/**/*.css",
            "#{root}/javascripts/**/*.js",
            "#{root}/images/**/*.*"]
        end

        files.each do |file|
          cache Pathname.new(file).relative_path_from(root)
        end

        network "*"
      end
    end
  end
end
