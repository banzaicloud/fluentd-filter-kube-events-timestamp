Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-kube-events-timestamp"
  spec.version = "0.1.3"
  spec.authors = ["Banzai Cloud"]
  spec.email   = ["info@banzaicloud.com"]
  spec.description   = %q{fluent filter plugin to map multiple timestamps into an additional one}
  spec.summary       = %q{fluent kubernetes events timestamps filter}
  spec.homepage      = "https://github.com/banzaicloud/fluentd-filter-kube-events-timestamp"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd", [">= 0.14.0", "< 2"]
  spec.add_development_dependency "rake", "~> 11.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "test-unit", "~> 3.2"
end
