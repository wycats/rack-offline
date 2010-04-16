require "spec_helper"

describe "Generating a basic manifest" do
  include Rack::Test::Methods

  self.app = Rack::Offline.configure do
    cache "images/masthead.png"
  end

  before do
    get "/"
  end

  it "returns the response as text/cache-manifest" do
    headers["Content-Type"].should == "text/cache-manifest"
  end

  it "returns a 200 status code" do
    status.should == 200
  end

  it "includes the text CACHE MANIFEST" do
    body.should =~ /\ACACHE MANIFEST\n/
  end

  it "includes the entry to be cached on its own line" do
    body.should =~ %r{^images/masthead.png$}
  end

  it "includes a cache-busting comment" do
    body.should =~ %r{^# .{64}$}
  end

  it "doesn't contain a network section" do
    body.should_not =~ %r{^NETWORK:}
  end

  it "doesn't contain a fallback section" do
    body.should_not =~ %r{^FALLBACK:}
  end
end