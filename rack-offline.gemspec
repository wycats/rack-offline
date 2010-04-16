path = File.expand_path("../lib", __FILE__)
$:.unshift(path) unless $:.include?(path)
require "rack/offline/version"

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'rack-offline'
  s.version     = Rack::Offline::VERSION
  s.summary     = 'A Rack toolkit for working with offline applications'
  s.description = 'A Rack endpoint that generates cache manifests and other useful ' \
                  'HTML5 offline utilities that are useful on the server-side. ' \
                  'Rack::Offline also provides a conventional Rails endpoint (' \
                  'Rails::Offline) that configures Rack::Offline using expected ' \
                  'Rails settings'

  s.author            = 'Yehuda Katz'
  s.email             = 'wycats@gmail.com'
  s.homepage          = 'http://www.yehudakatz.com'
  s.rubyforge_project = 'rack-offline'

  s.files        = Dir['CHANGELOG', 'README', 'LICENSE', 'lib/**/*']
  s.require_path = 'lib'
end
