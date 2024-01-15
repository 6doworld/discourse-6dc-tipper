# -*- encoding: utf-8 -*-
# stub: siwe 1.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "siwe".freeze
  s.version = "1.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Spruce Systems Inc.".freeze]
  s.bindir = "exe".freeze
  s.date = "2022-03-07"
  s.description = "Sign-In with Ethereum library implementation".freeze
  s.email = ["hello@spruceid.com".freeze]
  s.homepage = "https://login.xyz".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Sign-In with Ethereum".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<eth>.freeze, ["~> 0.5.1"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.21"])
  s.add_development_dependency(%q<solargraph>.freeze, ["~> 0.44"])
end
