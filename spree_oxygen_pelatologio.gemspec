# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_oxygen_pelatologio/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_oxygen_pelatologio'
  s.version     = SpreeOxygenPelatologio::VERSION
  s.summary     = 'Spree Commerce Oxygen Pelatologio Extension'
  s.description = 'Adds the ability to sync Oxygen Pelatologio data to Spree stores.'

  s.required_ruby_version = '>= 3.0'

  s.author    = 'OlympusOne'
  s.email     = 'info@olympusone.com'
  s.homepage  = 'https://github.com/olympusone/spree_oxygen_pelatologio'
  s.license   = 'AGPL-3.0-or-later'

  s.metadata = {
    "bug_tracker_uri"   => "#{s.homepage}/issues",
    "changelog_uri"     => "#{s.homepage}/releases/tag/v#{s.version}",
    "documentation_uri" => s.homepage,
    "homepage_uri"      => s.homepage,
    "source_code_uri"   => "#{s.homepage}/tree/v#{s.version}",
  }

  s.files        = Dir["{app,config,db,lib,vendor}/**/*", "LICENSE.md", "Rakefile", "README.md"].reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  spree_version = '>= 5.2.5'
  s.add_dependency 'spree', spree_version
  s.add_dependency 'spree_storefront', spree_version
  s.add_dependency 'spree_admin', spree_version
  s.add_dependency 'spree_extension'

  s.add_development_dependency 'spree_dev_tools'
end
