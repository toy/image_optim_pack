# encoding: UTF-8

Gem::Specification.new do |s|
  s.name        = 'image_optim_pack'
  s.version     = '0.5.3'
  s.summary     = %q{Precompiled binaries for image_optim: advpng, gifsicle, jhead, jpeg-recompress, jpegoptim, jpegtran, optipng, pngcrush, pngquant}
  s.homepage    = "http://github.com/toy/#{s.name}"
  s.authors     = ['Ivan Kuchin']
  s.license     = 'MIT'

  s.rubyforge_project = s.name

  s.metadata = {
    'bug_tracker_uri'   => "https://github.com/toy/#{s.name}/issues",
    'changelog_uri'     => "https://github.com/toy/#{s.name}/blob/master/CHANGELOG.markdown",
    'documentation_uri' => "https://www.rubydoc.info/gems/#{s.name}/#{s.version}",
    'source_code_uri'   => "https://github.com/toy/#{s.name}",
  }

  s.files         = `git ls-files`.split("\n")
  if defined?(gem_platform)
    s.platform = gem_platform

    vendor_dir = {
      'x86-linux' => 'linux-i686',
      'x86_64-openbsd' => 'openbsd-amd64',
    }[gem_platform] || begin
      gem_platform.sub(/^x86-/, 'i386-').split('-').reverse.join('-')
    end
    vendor_path = File.join('vendor', vendor_dir)
    fail "#{vendor_path} is not a dir" unless File.directory?(vendor_path)
    s.files.reject! do |path|
      parts = path.split('/')
      parts[0] == 'vendor' && parts[1] != vendor_dir
    end
  end
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w[lib]

  s.add_dependency 'image_optim', '~> 0.19'
  s.add_dependency 'fspath', '>= 2.1', '< 4'

  s.add_development_dependency 'rspec', '~> 3.0'
  if RUBY_VERSION >= '2.2'
    s.add_development_dependency 'rubocop', '~> 0.59'
  end
end
