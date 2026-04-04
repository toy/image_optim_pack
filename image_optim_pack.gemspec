# encoding: UTF-8

Gem::Specification.new do |s|
  s.name        = 'image_optim_pack'
  s.version     = '0.13.0'
  s.summary     = %q{Precompiled binaries for image_optim: advpng, gifsicle, jhead, jpeg-recompress, jpegoptim, jpegtran, optipng, oxipng, pngcrush, pngout, pngquant}
  s.homepage    = "https://github.com/toy/#{s.name}"
  s.authors     = ['Ivan Kuchin']
  s.license     = 'MIT'

  s.required_ruby_version = '>= 1.9.3'

  s.metadata = {
    'bug_tracker_uri'   => "https://github.com/toy/#{s.name}/issues",
    'changelog_uri'     => "https://github.com/toy/#{s.name}/blob/master/CHANGELOG.markdown",
    'documentation_uri' => "https://www.rubydoc.info/gems/#{s.name}/#{s.version}",
    'source_code_uri'   => "https://github.com/toy/#{s.name}",
  }

  s.files         = `git ls-files`.split("\n")
  if defined?(gemspec_path)
    gem_os, gem_arch, gem_version = File.basename(gemspec_path, File.extname(gemspec_path)).split('-').drop(1)

    s.platform = Gem::Platform.new([gem_arch, gem_os, gem_version])

    arch_aliases = {
      'x86_64' => %w[x86_64 amd64],
    }[gem_arch] || [gem_arch]

    possible_vendor_dirs = arch_aliases.map do |arch_alias|
      [gem_os, arch_alias, gem_version].compact.join('-')
    end

    existing_vendor_dirs = possible_vendor_dirs.select do |vendor_dir|
      File.directory?(File.join('vendor', vendor_dir))
    end

    vendor_dir = if existing_vendor_dirs.length == 1
      existing_vendor_dirs.first
    else
      message = existing_vendor_dirs.empty? ? 'no vendor dir' : 'multiple vendor dirs'
      fail "#{message} found for os #{gem_os} and arch #{gem_arch} out of: #{possible_vendor_dirs.join(', ')}"
    end

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
  if RUBY_VERSION >= '2.5'
    s.add_development_dependency 'rubocop', '~> 1.22', '!= 1.22.2'
    s.add_development_dependency 'rubocop-rspec', '~> 2.0'
  end
end
