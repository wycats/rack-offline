require "spec_helper"

describe "Generating a basic manifest" do
  include Rack::Test::Methods

  self.app = Rack::Offline.configure do
    cache "images/masthead.png"
  end

  it_should_behave_like "a cache manifest"

  it "doesn't contain a network section" do
    body.should_not =~ %r{^NETWORK:}
  end

  it "doesn't contain a fallback section" do
    body.should_not =~ %r{^FALLBACK:}
  end
  
  describe "cache-busting comment" do
    context "if no interval is specified" do
      self.app = Rack::Offline.configure do
        cache "images/masthead.png"
      end

      it_should_behave_like "uncached cache manifests"
    end

    context "if an interval is specified" do
      INTERVAL = 15
      self.app = Rack::Offline.configure(:cache_interval => INTERVAL) do
        cache "images/masthead.png"
      end
      
      before do
        @interval = INTERVAL
      end
      it_should_behave_like "uncached cache manifests"
    end
  end
end