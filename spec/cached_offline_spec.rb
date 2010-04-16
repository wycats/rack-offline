require "spec_helper"
require "fileutils"

describe "Generating a manifest in cached mode" do
  include Rack::Test::Methods

  root = File.expand_path("../fixture_root", __FILE__)
  self.app = Rack::Offline.configure(:root => root, :cache => true) do
    cache "hello.html"
    cache "hello.css"
    cache "javascripts/hello.js"
  end

  before :all do
    FileUtils.rm_rf File.expand_path("../fixture_root", __FILE__)
  end

  before do
    get "/"
  end

  it "returns the same cache-busting header every time" do
    
  end

  # it "returns the response as text/cache-manifest" do
  #   headers["Content-Type"].should == "text/cache-manifest"
  # end
  # 
  # it "returns a 200 status code" do
  #   status.should == 200
  # end
  # 
  # it "includes the text CACHE MANIFEST" do
  #   body.should =~ /\ACACHE MANIFEST\n/
  # end
  # 
  # it "includes the entry to be cached on its own line" do
  #   body.should =~ %r{^images/masthead.png$}
  # end
  # 
  # it "includes a cache-busting comment" do
  #   body.should =~ %r{^# .{64}$}
  # end
  # 
  # it "doesn't contain a network section" do
  #   body.should_not =~ %r{^NETWORK:}
  # end
  # 
  # it "doesn't contain a fallback section" do
  #   body.should_not =~ %r{^FALLBACK:}
  # end
end