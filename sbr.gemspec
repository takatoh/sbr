# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sbr/version'

Gem::Specification.new do |spec|
  spec.name          = "sbr"
  spec.version       = Sbr::VERSION
  spec.authors       = ["takatoh"]
  spec.email         = ["takatoh.m@gmail.com"]
  spec.summary       = %q{Post photo to Sombrero.}
  spec.description   = %q{Post photo to Sombrero.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.4.10"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "http"
  spec.add_runtime_dependency "nokogiri"
end
