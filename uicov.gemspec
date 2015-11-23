# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'uicov/version'

Gem::Specification.new do |spec|
  spec.name          = 'uicov'
  spec.version       = Uicov::VERSION
  spec.authors       = ['Alexey Lyanguzov']
  spec.email         = ['budabum@gmail.com']

  spec.summary       = %q{Tool to measure UI autotests coverage.}
  spec.description   = %q{Tool is applicable for any autotest's language becuase it parses log files.}
  spec.homepage      = 'https://github.com/budabum/uicov'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = 'http://RubyGems.org'
  # else
  #   raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
end
