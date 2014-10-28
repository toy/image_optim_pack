# image\_optim\_pack

Precompiled binaries for [`image_optim`](https://github.com/toy/image_optim).

Contains binaries for Mac OS X (>= 10.6, i386 and x86\_64) and Linux (i686 and x86\_64).

## Binaries and libraries

* [advpng](http://advancemame.sourceforge.net/doc-advpng.html) by Andrea Mazzoleni and Filipe Estima ([GNU GPLv3](acknowledgements/advancecomp.txt))
	* contains parts of [7z](http://7-zip.org) by Igor Pavlov with modifications by Andrea Mazzoleni ([license](acknowledgements/7z.txt))
	* and [zopfli](https://code.google.com/p/zopfli/) by Lode Vandevenne and Jyrki ([license](acknowledgements/zopfli.txt), [contributors](acknowledgements/zopfli-contributors.txt))
* [gifsicle](http://lcdf.org/gifsicle/) by Eddie Kohler ([GNU GPLv2](acknowledgements/gifsicle.txt))
* [jhead](http://sentex.net/~mwandel/jhead/) by Matthias Wandel ([public domain](acknowledgements/jhead.txt))
* [jpegoptim](http://www.kokkonen.net/tjko/projects.html) by Timo Kokkonen ([GNU GPLv2](acknowledgements/jpegoptim.txt) or later)
* [libjpeg and jpegtran](http://ijg.org/) by the Independent JPEG Group ([license](acknowledgements/libjpeg.txt))
* [libpng](http://libpng.org/pub/png/) by Guy Eric Schalnat, Andreas Dilger, Glenn Randers-Pehrson and others ([license](acknowledgements/libpng.txt))
* [optipng](http://optipng.sourceforge.net/) by Cosmin Truta ([license](acknowledgements/optipng.txt), [authors](acknowledgements/optipng-authors.txt))
	* contains code based in part on the work of Miyasaka Masaru for BMP support ([license](acknowledgements/bmp2png.txt))
	* and David Koblas for GIF support ([license](acknowledgements/gifread.txt))
* [pngcrush](http://pmt.sourceforge.net/pngcrush/) by Glenn Randers-Pehrson, portions by Greg Roelofs ([license](acknowledgements/pngcrush.txt))
	* contains [cexcept](http://www.nicemice.net/cexcept/) interface by Adam M. Costello and Cosmin Truta ([license](acknowledgements/cexcept.txt))
* [pngquant](http://pngquant.org/) by Kornel Lesiński based on code by Greg Roelofs and Jef Poskanzer after an idea by Stefan Schneider ([license](acknowledgements/pngquant.txt))
* [zlib](http://zlib.net/) by Jean-Loup Gailly and Mark Adler ([license](acknowledgements/zlib.txt))

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

Mac OS X binaries and libraries are built on host, others using vagrant.

```sh
script/run # Build and test all for all oses and architectures
script/run NO_HALT=1 # Don't halt VMs after building

make all # Build and copy all to output directory for current os/arch
make run # => all

make test # `all` and test bins for current os/arch

make download # Download archives
make build # Build all without copying to output directory

make livecheck # Check versions
make update-versions # Update versions in Makefile

make clean # Remove build and output directories for current os/arch
make clean-all # Remove build root and output root directories
make clobber # `claen-all` and remove download directory
```

## Copyright

Copyright (c) 2014 Ivan Kuchin. See [LICENSE.txt](LICENSE.txt) for details.
