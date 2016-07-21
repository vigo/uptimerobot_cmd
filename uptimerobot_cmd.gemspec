# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'uptimerobot_cmd/version'

Gem::Specification.new do |spec|
  spec.name          = "uptimerobot_cmd"
  spec.version       = UptimerobotCmd::VERSION
  spec.authors       = ["Uğur Özyılmazel"]
  spec.email         = ["ugurozyilmazel@gmail.com"]

  spec.summary       = %q{Commandline client for Uptimerobot service}
  spec.description   = %q{Manage your Uptimerobot monitors from command-line}
  spec.homepage      = "https://github.com/vigo/uptimerobot_cmd"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.1", ">= 1.1.10"
  spec.add_development_dependency "vcr", "~> 3.0", ">= 3.0.3"
  spec.add_development_dependency "webmock", "~> 2.1"
end
