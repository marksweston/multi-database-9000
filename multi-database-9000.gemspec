# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'multi-database-9000/version'

Gem::Specification.new do |spec|
  spec.name          = "multi-database-9000"
  spec.version       = MultiDatabase9000::VERSION
  spec.authors       = ["Mark Weston", "Stefania Cardenas", "Colin Frankish"]
  spec.email         = ["mark@markweston.me.uk"]
  spec.summary       = %q{Enables Rails apps with multiple databases to handle migrations and rake tasks transparently}
  spec.description   = %q{See README.md for details}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", ">= 3.0"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "aruba"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "pry"
  spec.add_runtime_dependency "rails", ">= 4.0"
end
