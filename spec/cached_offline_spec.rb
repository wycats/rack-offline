require "spec_helper"
require "fileutils"

describe "Generating a manifest in cached mode" do
  include Rack::Test::Methods

  def self.new_app(&block)
    root = File.expand_path("../fixture_root", __FILE__)
    Rack::Offline.configure(:root => root, :cache => true) do
      cache "hello.html"
      cache "hello.css"
      cache "javascripts/hello.js"
      instance_eval(&block) if block_given?
    end
  end

  def self.setup_fixtures
    fixture_root = Pathname.new(File.expand_path("../fixture_root", __FILE__))
    FileUtils.rm_rf(fixture_root)
    FileUtils.mkdir_p(fixture_root)

    File.open(fixture_root.join("hello.css"), "w") do |file|
      file.puts "#hello {\n  display: false\n}\n"
    end

    File.open(fixture_root.join("hello.html"), "w") do |file|
      file.puts "<!DOCTYPE html>\n<html manifest='hello.manifest'>\n</html>"
    end

    FileUtils.mkdir_p(fixture_root.join("javascripts"))
    File.open(fixture_root.join("javascripts/hello.js"), "w") do |file|
      file.puts "var x = 1;"
    end
  end

  def self.reload_server
    setup_fixtures
    self.app = new_app
  end

  def reload_server
    self.class.reload_server
  end

  before :all do
    reload_server
  end

  before do
    get "/"
  end

  it_should_behave_like "a cache manifest"

  it "returns the same cache-busting header every time" do
    cache_buster = body[/^# .{64}$/]
    get "/"
    body[/^# .{64}$/].should == cache_buster
  end

  it "updates the cache-busting header if the files change and the server restarts" do
    cache_buster = body[/^# .{64}$/]

    root = File.expand_path("../fixture_root", __FILE__)
    File.open("#{root}/hello.css", "w") {|file| file.puts "OMG"}

    self.class.app = self.class.new_app

    with_session :secondary do
      get "/"
      body[/^# .{64}$/].should_not == cache_buster
    end

    reload_server
  end

  it "doesn't contain a network section" do
    body.should_not =~ %r{^NETWORK:}
  end

  it "doesn't contain a fallback section" do
    body.should_not =~ %r{^FALLBACK:}
  end

  it "does contain a network section" do
    self.class.app = self.class.new_app{ network "/" }
    with_session :new_app_with_network do
      get "/" do
        body.should =~ %r{^NETWORK:}
      end
    end
  end

  it "does contain a fallback section" do
    self.class.app = self.class.new_app{ fallback("/" => "/offline.html") }
    with_session :new_app_with_offline do
      get "/"
      body.should =~ %r{^FALLBACK:}
    end
  end

end
