$:.push File.expand_path("../lib", __FILE__)
require "caching_with_tags/version"

Gem::Specification.new do |s|
  s.name        = "caching_with_tags"
  s.version     = CachingWithTags::VERSION
  s.authors     = ["Vitaly Tsevan"]
  s.email       = ["vzevan@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Realisation of cache tagging for rails}
  s.description = %q{Realisation of cache tagging for rails}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "rails"
end
