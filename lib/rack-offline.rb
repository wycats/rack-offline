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
      most_recent_only = options.delete(:most_recent_only)
      block  = cache_block(Pathname.new(root), most_recent_only) unless block_given?

      opts = {
        :cache  => config.cache_classes,
        :root   => root,
        :logger => Rails.logger,
      }.merge(options)

      super(opts, &block)
    end

  private

    def cache_block(root, most_recent_only = false)
      Proc.new do
        if Rails.version >= "3.1" && Rails.configuration.assets.enabled
          files = Dir[
            "#{root}/**/*.html",
            "#{root}/assets/**/*.{js,css,jpg,png,gif}"]
        else
          files = Dir[
            "#{root}/**/*.html",
            "#{root}/stylesheets/**/*.css",
            "#{root}/javascripts/**/*.js",
            "#{root}/images/**/*.*"]
        end

        strip_fingerprint = lambda do |path|
          path.gsub(/^(.+)-[0-9a-f]{7,40}\.([^.]+)$/, '\1.\2')
        end

        if most_recent_only
          files = files.sort_by { |f| File.mtime(f) }.reverse.reduce([]) do |list, file|
            list << file unless list.map(&strip_fingerprint).include?(strip_fingerprint.call(file))
            list
          end
        end

        files.each do |file|
          cache ActionController::Base.helpers.asset_path(Pathname.new(file).relative_path_from(root))
        end

        network "*"
      end
    end
  end
end
