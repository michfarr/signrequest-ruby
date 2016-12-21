# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'signrequest/version'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name             = 'signrequest'
  spec.version          = Signrequest::VERSION
  spec.authors          = ['michfarr']
  spec.email            = ['etnunc@protonmail.com']
  spec.date             = Time.now.utc.strftime('%Y-%m-%d')

  spec.summary          = 'Gem for navigating SignRequest V1 API'
  spec.description      = "We don't need no stinkin' description."
  spec.homepage         = 'https://github.com/michfarr/signrequest-ruby'
  spec.license          = 'MIT'

  # Prevent pushing this gem to RubyGems.org.
  # To allow pushes either set the 'allowed_push_host' to allow pushing to a
  # single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'http://mygemserver.com'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.extra_rdoc_files = ['README.md']
  spec.files            = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir           = 'exe'
  spec.executables      = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths    = ['lib']

  # Testing
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.46'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'guard-rubocop', '~> 1.2'
  spec.add_development_dependency 'rb-fsevent', '~> 0.9'
  spec.add_development_dependency 'terminal-notifier-guard', '~> 1.7'

  # General
  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'

  # Runtime
  spec.add_runtime_dependency 'rest-client', '~> 2.0'
  spec.add_runtime_dependency 'oj', '~> 2.18'
end
# rubocop:enable Metrics/BlockLength
