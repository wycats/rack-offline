require "rubygems"
require "bundler"
Bundler.setup

$:.unshift File.expand_path("../../lib", __FILE__)

require "rack/offline"
Bundler.require(:test)

module Rack::Test::Methods
  def self.included(klass)
    class << klass
      attr_accessor :app
    end
  end

  def body
    last_response.body
  end

  def status
    last_response.status
  end

  def headers
    last_response.headers
  end

  def app
    self.class.app
  end
end

shared_examples_for "a cache manifest" do
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

  it "includes a cache-busting comment" do
    body.should =~ %r{^# .{64}$}
  end
end