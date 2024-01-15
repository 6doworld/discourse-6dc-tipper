# -*- encoding: utf-8 -*-
# stub: eth 0.5.6 ruby lib

Gem::Specification.new do |s|
  s.name = "eth".freeze
  s.version = "0.5.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/q9f/eth.rb/issues", "changelog_uri" => "https://github.com/q9f/eth.rb/blob/main/CHANGELOG.md", "documentation_uri" => "https://q9f.github.io/eth.rb/", "github_repo" => "https://github.com/q9f/eth.rb", "source_code_uri" => "https://github.com/q9f/eth.rb" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Steve Ellis".freeze, "Afri Schoedon".freeze]
  s.bindir = "exe".freeze
  s.date = "2022-07-01"
  s.description = "Library to handle Ethereum accounts, messages, and transactions.".freeze
  s.email = ["email@steveell.is".freeze, "ruby@q9f.cc".freeze]
  s.homepage = "https://github.com/q9f/eth.rb".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new([">= 2.6".freeze, "< 4.0".freeze])
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Ruby Ethereum library.".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<keccak>.freeze, ["~> 1.3"])
  s.add_runtime_dependency(%q<konstructor>.freeze, ["~> 1.0"])
  s.add_runtime_dependency(%q<rbsecp256k1>.freeze, ["~> 5.1"])
  s.add_runtime_dependency(%q<openssl>.freeze, [">= 2.2", "< 4.0"])
  s.add_runtime_dependency(%q<scrypt>.freeze, ["~> 3.0"])
end
