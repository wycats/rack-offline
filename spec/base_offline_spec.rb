require "spec_helper"

describe "Generating a basic manifest" do
  include Rack::Test::Methods

  self.app = Rack::Offline.configure(:root => File.expand_path("../fixture_root", __FILE__)) do
    cache "hello.css"
  end

  it_should_behave_like "a cache manifest"

  it "returns the same cache-busting comment when files haven't changed" do
    cache_buster = body[/^# .{64}$/]
    get "/"
    body[/^# .{64}$/].should == cache_buster
  end

  it "returns a different cache-busting comment when file has changed" do
    cache_buster = body[/^# .{64}$/]

    root = File.expand_path("../fixture_root", __FILE__)
    File.open("#{root}/hello.css", "w") {|file| file.puts "OMG"}

    get "/"
    body[/^# .{64}$/].should_not == cache_buster
  end

  it "doesn't contain a network section" do
    body.should_not =~ %r{^NETWORK:}
  end

  it "doesn't contain a fallback section" do
    body.should_not =~ %r{^FALLBACK:}
  end
end
