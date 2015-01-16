# encoding: UTF-8

Gem::Specification.new do |s|
  s.name        = 'image_optim_pack'
  s.version     = '0.2.1.20150107'
  s.summary     = %q{Precompiled binaries for image_optim: advpng, gifsicle, jhead, jpegoptim, jpegtran, optipng, pngcrush, pngquant}
  s.homepage    = "http://github.com/toy/#{s.name}"
  s.authors     = ['Ivan Kuchin']
  s.license     = 'MIT'

  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w[lib]

  s.add_dependency 'image_optim', '~> 0.20'
  s.add_dependency 'fspath', '~> 2.1'

  s.add_development_dependency 'versionomy', '~> 0.4.4'
  s.add_development_dependency 'rspec', '~> 3.0'
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('1.9.3')
    s.add_development_dependency 'rubocop', '~> 0.26'
  end
end
