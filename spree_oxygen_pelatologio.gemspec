# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_oxygen_pelatologio/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_oxygen_pelatologio'
  s.version     = SpreeOxygenPelatologio::VERSION
  s.summary     = "Spree Commerce Oxygen pelatologio Extension"
  s.required_ruby_version = '>= 3.0'

  s.author    = 'You'
  s.email     = 'you@example.com'
  s.homepage  = 'https://github.com/your-github-handle/spree_oxygen_pelatologio'
  s.license = 'AGPL-3.0-or-later'

  s.files        = Dir["{app,config,db,lib,vendor}/**/*", "LICENSE.md", "Rakefile", "README.md"].reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree', '>= 5.2.5'
  s.add_dependency 'spree_storefront', '>= 5.2.5'
  s.add_dependency 'spree_admin', '>= 5.2.5'
  s.add_dependency 'spree_extension'

  s.add_development_dependency 'spree_dev_tools'
end
