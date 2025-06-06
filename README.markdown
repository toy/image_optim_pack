[![Gem Version](https://img.shields.io/gem/v/image_optim_pack?logo=rubygems)](https://rubygems.org/gems/image_optim_pack)
[![Check](https://img.shields.io/github/actions/workflow/status/toy/image_optim_pack/check.yml?label=check&logo=github)](https://github.com/toy/image_optim_pack/actions/workflows/check.yml)
[![Rubocop](https://img.shields.io/github/actions/workflow/status/toy/image_optim_pack/rubocop.yml?label=rubocop&logo=rubocop)](https://github.com/toy/image_optim_pack/actions/workflows/rubocop.yml)
[![Docker build](https://img.shields.io/github/actions/workflow/status/toy/image_optim_pack/docker-build.yml?label=docker+build&logo=docker)](https://github.com/toy/image_optim_pack/actions/workflows/docker-build.yml)
[![Livecheck](https://img.shields.io/github/actions/workflow/status/toy/image_optim_pack/livecheck.yml?label=livecheck&logo=github)](https://github.com/toy/image_optim_pack/actions/workflows/livecheck.yml)
[![Build](https://img.shields.io/github/actions/workflow/status/toy/image_optim_pack/build.yml?label=build&logo=github)](https://github.com/toy/image_optim_pack/actions/workflows/build.yml)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/toy/image_optim_pack?logo=codeclimate)](https://codeclimate.com/github/toy/image_optim_pack)
[![Depfu](https://img.shields.io/depfu/toy/image_optim_pack)](https://depfu.com/github/toy/image_optim_pack)
[![Inch CI](https://inch-ci.org/github/toy/image_optim_pack.svg?branch=master)](https://inch-ci.org/github/toy/image_optim_pack)

# image\_optim\_pack

Precompiled binaries for [`image_optim`](https://github.com/toy/image_optim).

Contains binaries for Mac OS X (>= 10.12, x86\_64, arm64) and Linux (x86\_64).

A test application with latest `image_optim` and `image_optim_pack` is available on render: https://iopack.onrender.com/.

## Binaries and libraries

* [advpng](https://www.advancemame.it/doc-advpng.html) by Andrea Mazzoleni and Filipe Estima ([GNU GPLv3](acknowledgements/advancecomp.txt))
	* contains parts of [7z](https://7-zip.org) by Igor Pavlov with modifications by Andrea Mazzoleni ([license](acknowledgements/7z.txt))
	* and [zopfli](https://code.google.com/p/zopfli/) by Lode Vandevenne and Jyrki Alakuijala ([license](acknowledgements/zopfli.txt), [contributors](acknowledgements/zopfli-contributors.txt))
* [gifsicle](https://lcdf.org/gifsicle/) by Eddie Kohler ([GNU GPLv2](acknowledgements/gifsicle.txt))
* [jhead](https://www.sentex.ca/~mwandel/jhead/) by Matthias Wandel ([public domain](acknowledgements/jhead.txt))
* [jpeg-recompress](https://github.com/danielgtaylor/jpeg-archive) by Daniel G. Taylor ([license](acknowledgements/jpeg-archive.txt))
	* includes [Image Quality Assessment (IQA)](http://tdistler.com/iqa/) by Tom Distler ([license](acknowledgements/iqa.txt))
	* includes [SmallFry](https://github.com/dwbuiten/smallfry) by Derek Buitenhuis ([license](acknowledgements/smallfry.txt))
	* statically linked against mozjpeg, see below
* [jpegoptim](https://www.kokkonen.net/tjko/projects.html) by Timo Kokkonen ([GNU GPLv2](acknowledgements/jpegoptim.txt) or later)
* [libjpeg and jpegtran](https://ijg.org/) by the Independent JPEG Group ([license](acknowledgements/libjpeg.txt))
* [libjpeg-turbo](https://www.libjpeg-turbo.org/) by libjpeg-turbo Project ([license](acknowledgements/libjpeg-turbo.txt))
	* based on libjpeg, see above
	* includes [x86 SIMD extension for IJG JPEG library](https://cetus.sakura.ne.jp/softlab/jpeg-x86simd/jpegsimd.html) by Miyasaka Masaru ([license](acknowledgements/libjpeg-x86-simd.txt))
* [liblcms2](https://littlecms.com) by Marti Maria ([license](acknowledgements/liblcms2.txt))
* [libpng](http://libpng.org/pub/png/) by Guy Eric Schalnat, Andreas Dilger, Glenn Randers-Pehrson and others ([license](acknowledgements/libpng.txt))
* [mozjpeg](https://github.com/mozilla/mozjpeg) by Mozilla Research ([license](acknowledgements/mozjpeg.txt))
	* base on libjpeg and libjpeg-turbo, see above
* [optipng](http://optipng.sourceforge.net/) by Cosmin Truta ([license](acknowledgements/optipng.txt), [authors](acknowledgements/optipng-authors.txt))
	* contains code based in part on the work of Miyasaka Masaru for BMP support ([license](acknowledgements/bmp2png.txt))
	* and David Koblas for GIF support ([license](acknowledgements/gifread.txt))
* [oxipng](https://github.com/oxipng/oxipng) by Joshua Holmer ([license](acknowledgements/oxipng.txt))
* [pngcrush](https://pmt.sourceforge.io/pngcrush/) by Glenn Randers-Pehrson, portions by Greg Roelofs ([license](acknowledgements/pngcrush.txt))
	* contains [cexcept](http://www.nicemice.net/cexcept/) interface by Adam M. Costello and Cosmin Truta ([license](acknowledgements/cexcept.txt))
* [pngout](http://advsys.net/ken/utils.htm) by Ken Silverman ([license](acknowledgements/pngout.txt))
	* Linux and BSD ports by Jonathon Fowler (http://www.jonof.id.au/pngout)
	* Mac OS X port by Ken Silverman, with assistance by Jonathon Fowler
* [pngquant](https://pngquant.org/) by Kornel Lesiński based on code by Greg Roelofs and Jef Poskanzer after an idea by Stefan Schneider ([license](acknowledgements/pngquant.txt))
* [zlib](https://zlib.net/) by Jean-Loup Gailly and Mark Adler ([license](acknowledgements/zlib.txt))

**NOTE: On FreeBSD and OpenBSD `make` is not the GNU Make, so `gmake` should be used instead.**

You can download all source code using gnu make download target:

```sh
make download
```

## Installation

```sh
gem install image_optim image_optim_pack
```

Or add to your `Gemfile`:

```ruby
gem 'image_optim'
gem 'image_optim_pack'
```

## Development

Mac OS X binaries and libraries are built on host, others using containers.

```sh
script/run # Build and test all for all oses and architectures
script/run NO_HALT=1 # Don't halt VMs after building
script/run NO_UP=1 # Don't start VMs before building (will fail if not already running)
script/run darwin 64 # Build only platforms matching darwin or 64

make # Build all tools and copy them to vendor/OS-ARCH for current OS and ARCH, then test
make all # same

script/livecheck # Check versions
make update-versions # Update versions in Makefile

make download # Download archives
make download-tidy-up # Remove old archives
make build # Build all without copying to output directory

make test # Test bins for current os/arch
make test -i # Continue if one of bins fail

make clean # Remove build and output directories for current os/arch
make clean-all # Remove build root and output root directories
make clobber # `clean-all` and remove download directory
```

## Docker

This project includes a `Dockerfile` in the root, which builds a minimal image with most binaries included.

#### Running

```bash
docker run --rm ghcr.io/toy/image_optim --version # image_optim version
docker run --rm ghcr.io/toy/image_optim --info # image_optim info including bin versions
docker run --rm -v "$PWD":/here -w /here ghcr.io/toy/image_optim image-in-this-folder.jpg
```

#### Building

```bash
make docker-build # will be tagged with latest and current date in format %Y%m%d
make docker-push # will push tags created by docker-build
```

## Copyright

Copyright (c) 2014-2025 Ivan Kuchin. See [LICENSE.txt](LICENSE.txt) for details.
