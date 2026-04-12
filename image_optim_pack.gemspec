# encoding: UTF-8

Gem::Specification.new do |s|
  s.name        = 'image_optim_pack'
  s.version     = '0.13.1'
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

  s.files = Dir[*%w[
    .dockerignore
    .gitignore
    .rubocop.yml
    checksums.mk
    Gemfile
    LICENSE.txt
    Makefile
    *.markdown
    Dockerfile*
    *.gemspec
    {.github,acknowledgements,lib,patches,script,spec,vendor}/**/*
  ]].reject(&File.method(:directory?))

  if defined?(gemspec_path)
    platform_parts = File.basename(gemspec_path, File.extname(gemspec_path)).split('-').drop(1)
    s.platform = Gem::Platform.new(platform_parts.values_at(1, 0, 2))

    all_vendor_dirs = s.files.filter_map do |path|
      parts = path.split('/')
      parts[1] if parts[0] == 'vendor'
    end.uniq

    vendor_dirs = all_vendor_dirs.select do |vendor_dir|
      s.platform =~ Gem::Platform.new(vendor_dir.split('-').values_at(1, 0, 2))
    end

    expected_vendor_dirs = s.platform.os == 'linux' && !s.platform.version ? 2 : 1

    unless vendor_dirs.length == expected_vendor_dirs
      fail "expected #{expected_vendor_dirs}, got #{vendor_dirs.length} (#{vendor_dirs.join(', ')}) for #{s.platform}"
    end

    s.files.reject! do |path|
      parts = path.split('/')
      parts[0] == 'vendor' && !vendor_dirs.include?(parts[1])
    end
  end

  s.test_files    = Dir['spec/**/*.*']
  s.require_paths = %w[lib]

  s.add_dependency 'image_optim', '~> 0.19'
  s.add_dependency 'fspath', '>= 2.1', '< 4'

  s.add_development_dependency 'rspec', '~> 3.0'
  if RUBY_VERSION >= '2.5'
    s.add_development_dependency 'rubocop', '~> 1.22', '!= 1.22.2'
    s.add_development_dependency 'rubocop-rspec', '~> 2.0'
  end
end
