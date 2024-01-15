# -*- encoding: utf-8 -*-
# stub: sha3 1.0.5 ruby lib
# stub: ext/sha3/extconf.rb

Gem::Specification.new do |s|
  s.name = "sha3".freeze
  s.version = "1.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/johanns/sha3/CHANGELOG.md", "homepage_uri" => "https://github.com/johanns/sha3", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/johanns/sha3" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Johanns Gregorian".freeze]
  s.bindir = "exe".freeze
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIETDCCArSgAwIBAgIBATANBgkqhkiG9w0BAQsFADA2MQswCQYDVQQDDAJpbzET\nMBEGCgmSJomT8ixkARkWA2pzZzESMBAGCgmSJomT8ixkARkWAmlvMB4XDTIyMTAy\nNDA2MzcxMVoXDTIzMTAyNDA2MzcxMVowNjELMAkGA1UEAwwCaW8xEzARBgoJkiaJ\nk/IsZAEZFgNqc2cxEjAQBgoJkiaJk/IsZAEZFgJpbzCCAaIwDQYJKoZIhvcNAQEB\nBQADggGPADCCAYoCggGBALQTl5BGmtYGvljWwOTxe2Uul7RoBcSOwFUh03qUvHJf\n1LmWr6y1j97ogl/VffBXpbtTU4adZa+qTxfMs7GpfKDjikSIieZ7SrMNB68zCH0e\nundHx+bMutN7919rviHfGyaXlQK4SsuWUl4AOlgT69VPQp6dOBYY9T78jbr/ZcG6\n+mDlRpNfPVg5i67euvpR5dO9SpO1HNoHmzx5L4wYNr9QykIft1oA+Ne+SAF66ykn\nagugF/R0Q7s+5Bpt3gr6SF2CvKsNJ2IS5TJO9unhLZ+h8FO7dcQw1EuJ31uHQKiD\nrWUv2tnKCvLkHg0S69VeQtQv58dklJ3iFJcSen4VRtC7r5JMEd1VrdpXU4JQ54gY\ntWrqWmazF9SOErbgvDlJgmlkMMkX6aoZ21/f1s6Z2myzP3KkRBjCf51BrgHTXTJD\n28ANp21H0o0HhrpVFJVDjToXRLczsw0O9lnL+khzkeZoc+YTZuvJDLKokavXhb4a\nvESgRttXjyN5jBKY7yFhKQIDAQABo2UwYzAJBgNVHRMEAjAAMAsGA1UdDwQEAwIE\nsDAdBgNVHQ4EFgQUKmyX3Q2uwTPM9S5+K/5kg7qe3ugwFAYDVR0RBA0wC4EJaW9A\nanNnLmlvMBQGA1UdEgQNMAuBCWlvQGpzZy5pbzANBgkqhkiG9w0BAQsFAAOCAYEA\nTexWHx3uLVObT+ylm3OE8Iue3cHdrDVE3zSjo8VlU3u1WBznH9MdoiPB7wux61Zx\njXUzBUaT7y7JnDaVGnECkpHXhfvPOYHBgkqEws6i79lAk/Va2U7EVPj0moM9d4Hv\n12V8YVM1Z9QnfwBVo7YGb5o7W8lr01jj1gT+Qcw+kln7M3Y9RB+jQ4DwySHVIEMc\nOw7//MF7bhCz6T5uAOXlGe88wTHKW+fO1AmW5MIQZUojR5Ioxm80v2YdW/JnQZ1l\n3VFpCutilnhDuzSw3DhgxReX7AK42aXFFclIzi11twW4KUPdt1KIvaoL/DgbZivl\nPVG86dx4gfax2Mc2PiM+d1DiSllh+chh4dqRkIyhj0S4V7McQHkwW1ZBJ3kDf5rt\n1O/udKquzj7egb6uceqzBB40W/1/CsNkGNpNZ8Bk8lrTmKw+3bJpj+nKWxovmF2p\nVhzZDQf2jkcjBXKNA9Z5ku7g0TCR1/Y1V3ODgkTLqhw+kQZmlbQEVzcwxGk9eL8z\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2022-10-24"
  s.description = "A XKCP based native (C) binding to SHA3 (FIPS 202) cryptographic hashing algorithm.".freeze
  s.email = ["io+sha3@jsg.io".freeze]
  s.extensions = ["ext/sha3/extconf.rb".freeze]
  s.files = ["ext/sha3/extconf.rb".freeze]
  s.homepage = "https://github.com/johanns/sha3".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "SHA3 (FIPS 202) cryptographic hashing algorithm".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<rake-compiler>.freeze, ["~> 1.2"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.11"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.37"])
  s.add_development_dependency(%q<rubocop-rake>.freeze, ["~> 0.6"])
  s.add_development_dependency(%q<rubocop-rspec>.freeze, ["~> 2.14"])
end
