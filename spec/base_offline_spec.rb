require "spec_helper"

describe "Generating a basic manifest" do
  include Rack::Test::Methods

  self.app = Rack::Offline.configure do
    cache "images/masthead.png"
  end

  it_should_behave_like "a cache manifest"

  it "returns a different cache-busting comment each time" do
    cache_buster = body[/^# .{64}$/]
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