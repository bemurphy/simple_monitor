# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simple_monitor/version"

Gem::Specification.new do |s|
  s.name        = "simple_monitor"
  s.version     = SimpleMonitor::VERSION
  s.authors     = ["Brendon Murphy"]
  s.email       = ["xternal1+github@gmail.com"]
  s.licenses    = ["MIT"]
  s.homepage    = ""
  s.summary     = %q{Send alerts based on simple monitored conditions in your app}
  s.description = s.description

  s.rubyforge_project = "simple_monitor"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
