# encoding: UTF-8

Gem::Specification.new do |s|
  s.name        = 'image_optim_pack'
  s.version     = '0.0.0'
  s.summary     = %q{Precompiled binaries for image_optim: advpng, gifsicle, jhead, jpegoptim, jpegtran, optipng, pngcrush, pngquant}
  s.homepage    = "http://github.com/toy/#{s.name}"
  s.authors     = ['Ivan Kuchin']
  s.license     = 'MIT'

  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w[lib]

  s.add_dependency 'image_optim'
  s.add_dependency 'fspath', '~> 2.1'
  s.add_development_dependency 'versionomy', '~> 0.4.4'
end
