# -*- encoding: utf-8 -*-
# stub: pkg-config 1.5.1 ruby lib

Gem::Specification.new do |s|
  s.name = "pkg-config".freeze
  s.version = "1.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "msys2_mingw_dependencies" => "pkg-config" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Kouhei Sutou".freeze]
  s.date = "2022-11-23"
  s.description = "pkg-config can be used in your extconf.rb to properly detect need libraries for compiling Ruby native extensions".freeze
  s.email = ["kou@cozmixng.org".freeze]
  s.homepage = "https://github.com/ruby-gnome/pkg-config".freeze
  s.licenses = ["LGPLv2+".freeze]
  s.rubygems_version = "3.4.19".freeze
  s.summary = "A pkg-config implementation for Ruby".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<test-unit>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
end
