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

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/vigo/uptimerobot_cmd.git"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 2.1', '>= 2.1.4'
  spec.add_development_dependency 'rake', '~> 13.0', '>= 13.0.1'
  spec.add_development_dependency 'minitest', '~> 5.14'
  spec.add_development_dependency 'minitest-reporters', '~> 1.4', '>= 1.4.2'

  spec.add_runtime_dependency 'httparty', '~> 0.13.7'
  spec.add_runtime_dependency 'terminal-table', '~> 1.6'
  spec.add_runtime_dependency 'thor', '~> 0.19.1'
end
