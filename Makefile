all :

# ====== VERSIONS ======

ADVANCECOMP_VER := 2.1
GIFSICLE_VER := 1.92
JHEAD_VER := 3.03
JPEGARCHIVE_VER := 2.1.1
JPEGOPTIM_VER := 1.4.6
LIBJPEG_VER := 9c
LIBMOZJPEG_VER := 3.1
LIBPNG_VER := 1.6.37
LIBZ_VER := 1.2.11
OPTIPNG_VER := 0.7.7
PNGCRUSH_VER := 1.8.13
PNGQUANT_VER := 2.12.3

# ====== CHECKSUMS ======

include checksums.mk

# ====== CONSTANTS ======

OS := $(shell uname -s | tr A-Z a-z)
ARCH := $(shell uname -m)

IS_DARWIN := $(findstring darwin,$(OS))
IS_LINUX := $(findstring linux,$(OS))
IS_BSD := $(findstring bsd,$(OS))
IS_FREEBSD := $(findstring freebsd,$(OS))
IS_OPENBSD := $(findstring openbsd,$(OS))
DLEXT := $(if $(IS_DARWIN),.dylib,.so)
HOST := $(ARCH)-$(if $(IS_DARWIN),apple,pc)-$(OS)

DL_DIR := $(CURDIR)/download
BUILD_ROOT_DIR := $(CURDIR)/build
BUILD_DIR := $(BUILD_ROOT_DIR)/$(OS)-$(ARCH)
OUTPUT_ROOT_DIR := $(CURDIR)/vendor
OUTPUT_DIR := $(OUTPUT_ROOT_DIR)/$(OS)-$(ARCH)
$(shell mkdir -p $(DL_DIR) $(BUILD_DIR) $(OUTPUT_DIR))

ANSI_RED=\033[31m
ANSI_GREEN=\033[32m
ANSI_MAGENTA=\033[35m
ANSI_RESET=\033[0m

# ====== HELPERS ======

downcase = $(shell echo $1 | tr A-Z a-z)

ln_s := ln -sf
tar := $(shell if command -v gtar >/dev/null 2>&1; then echo gtar; else echo tar; fi)
sha256sum := $(shell if command -v sha256sum >/dev/null 2>&1; then echo sha256sum; elif command -v shasum >/dev/null 2>&1; then echo shasum -a 256; else echo sha256; fi)

# ====== ARCHIVES ======

ARCHIVES :=

# $1 - name of archive
define archive
ARCHIVES += $1
$1_DIR := $(BUILD_DIR)/$(call downcase,$1)
$1_TGZ := $(DL_DIR)/$(call downcase,$1)-$($1_VER).tar.gz
$1_EXTRACTED := $$($1_DIR)/__$$(notdir $$($1_TGZ))__
$$($1_EXTRACTED) : $$($1_TGZ)
	rm -rf $$(@D)
	echo "$$($1_SHA256)  $$($1_TGZ)" | $(sha256sum) -c
	mkdir $$(@D)
	$(tar) -C $$(@D) --strip-components=1 -xzf $$<
	touch $$(@D)/__$$(notdir $$<)__
endef

# $1 - name of archive
# $2 - url of archive with [VER] for replace with version
define archive-dl
$(call archive,$1)
# download archive from url
$$($1_TGZ) :
	while ! mkdir $$@.lock 2> /dev/null; do sleep 1; done
	wget -q -O $$@.tmp $(subst [VER],$($1_VER),$(strip $2))
	mv $$@.tmp $$@
	rm -r $$@.lock
endef

$(eval $(call archive-dl,ADVANCECOMP, https://github.com/amadvance/advancecomp/releases/download/v[VER]/advancecomp-[VER].tar.gz))
$(eval $(call archive-dl,GIFSICLE,    http://www.lcdf.org/gifsicle/gifsicle-[VER].tar.gz))
$(eval $(call archive-dl,JHEAD,       http://www.sentex.net/~mwandel/jhead/jhead-[VER].tar.gz))
$(eval $(call archive-dl,JPEGARCHIVE, https://github.com/danielgtaylor/jpeg-archive/archive/[VER].tar.gz))
$(eval $(call archive-dl,JPEGOPTIM,   http://www.kokkonen.net/tjko/src/jpegoptim-[VER].tar.gz))
$(eval $(call archive-dl,LIBJPEG,     http://www.ijg.org/files/jpegsrc.v[VER].tar.gz))
$(eval $(call archive-dl,LIBMOZJPEG,  https://github.com/mozilla/mozjpeg/archive/v[VER].tar.gz))
$(eval $(call archive-dl,LIBPNG,      http://prdownloads.sourceforge.net/libpng/libpng-[VER].tar.gz?download))
$(eval $(call archive-dl,LIBZ,        http://prdownloads.sourceforge.net/libpng/zlib-[VER].tar.gz?download))
$(eval $(call archive-dl,OPTIPNG,     http://prdownloads.sourceforge.net/optipng/optipng-[VER].tar.gz?download))
$(eval $(call archive-dl,PNGCRUSH,    http://prdownloads.sourceforge.net/pmt/pngcrush-[VER]-nolib.tar.gz?download))
$(eval $(call archive-dl,PNGQUANT,    http://pngquant.org/pngquant-[VER]-src.tar.gz))

download : $(foreach archive,$(ARCHIVES),$($(archive)_TGZ))
.PHONY : download

download-tidy-up :
	rm -f $(filter-out $(foreach archive,$(ARCHIVES),$($(archive)_TGZ)),$(wildcard $(DL_DIR)/*.*))
.PHONY : download-tidy-up

checksum : download
	@$(sha256sum) $(foreach archive,$(ARCHIVES),$($(archive)_TGZ))
.PHONY : checksum

checksum-verify : download
	@printf '%s  %s\n' $(foreach archive,$(ARCHIVES),$($(archive)_SHA256) $($(archive)_TGZ)) | $(sha256sum) -c
.PHONY : checksum-verify

checksum-update : download
	@printf '%s := %s\n' $(foreach archive,$(ARCHIVES),$(archive)_SHA256 $(shell $(sha256sum) $($(archive)_TGZ) | cut -d ' ' -f 1)) > checksums.mk
.PHONY : checksum-update

# ====== PRODUCTS ======

PRODUCTS :=

# $1 - product name
# $2 - archive name ($1 if empty)
# $3 - path ($1 if empty)
define target-build
$1_PATH := $(or $3,$(call downcase,$1))
$1_BASENAME := $$(notdir $$($1_PATH))
$1_DIR := $($(or $2,$1)_DIR)
$1_TGZ := $($(or $2,$1)_TGZ)
$1_EXTRACTED := $($(or $2,$1)_EXTRACTED)
$1_TARGET := $$($1_DIR)/$$($1_PATH)
$$($1_TARGET) : DIR := $$($1_DIR)
$$($1_TARGET) : $$($1_EXTRACTED)
endef

# $1 - product name
# $2 - archive name ($1 if empty)
# $3 - basename ($1 if empty)
define target
$(call target-build,$1,$2,$3)
PRODUCTS += $1
$1_DESTINATION := $$(OUTPUT_DIR)/$$($1_BASENAME)
# copy product to output dir
$$($1_DESTINATION) : $$($1_TARGET)
	temppath=`mktemp "$(BUILD_DIR)"/tmp.XXXXXXXXXX` && \
		strip $$< -Sx -o "$$$$temppath" && \
		chmod 755 "$$$$temppath" && \
		mv "$$$$temppath" $$@
# short name target
$(call downcase,$1) : | $$($1_DESTINATION)
endef

$(eval $(call target,ADVPNG,ADVANCECOMP))
$(eval $(call target,GIFSICLE,,src/gifsicle))
$(eval $(call target,JHEAD))
$(eval $(call target,JPEG-RECOMPRESS,JPEGARCHIVE))
$(eval $(call target,JPEGOPTIM))
$(eval $(call target,JPEGTRAN,LIBJPEG,.libs/jpegtran))
$(eval $(call target,LIBJPEG,,libjpeg$(DLEXT)))
$(eval $(call target-build,LIBMOZJPEG,,libjpeg.a))
$(eval $(call target,LIBPNG,,libpng$(DLEXT)))
$(eval $(call target,LIBZ,,libz$(DLEXT)))
$(eval $(call target,OPTIPNG,,src/optipng/optipng))
$(eval $(call target,PNGCRUSH))
$(eval $(call target,PNGQUANT))

# ====== TARGETS ======

all : build
	@$(MAKE) test
.PHONY : all

build : $(call downcase,$(PRODUCTS))
.PHONY : build

ifdef IS_DARWIN
ldd := otool -L
else
ldd := ldd
endif

ldd-version :; $(ldd) --version
.PHONY : ldd-version

define check_exists
	@test -f $(OUTPUT_DIR)/$1 || \
		{ printf "$1: $(ANSI_RED)not found$(ANSI_RESET)\n"; exit 1; }
endef

define check_version
	@$(OUTPUT_DIR)/$1 $2 | fgrep -q $3 || \
		{ printf "$1: $(ANSI_RED)Expected $3, got $$($(OUTPUT_DIR)/$1 $2)$(ANSI_RESET)\n"; exit 1; }
endef

define check_arch
	@file -b $(OUTPUT_DIR)/$1 | fgrep -q '$(ARCH_STRING)' || \
		{ printf "$1: $(ANSI_RED)Expected $(ARCH_STRING), got $$(file -b $(OUTPUT_DIR)/$1)$(ANSI_RESET)\n"; exit 1; }
endef

define check_output
	@printf "$1: $(ANSI_GREEN)$3$(ANSI_RESET) / $(ANSI_MAGENTA)$(ARCH_STRING)$(ANSI_RESET)\n"
endef

define check_shlib
	@! $(ldd) $(OUTPUT_DIR)/$1 | egrep -o "[^: 	]+/[^: 	]+" | egrep -v "^(@loader_path|/lib|/lib64|/usr|$(OUTPUT_DIR))/"
endef

define check_lib
	$(call check_exists,$1)
	$(call check_arch,$1)
	$(call check_output,$1,,-)
	$(call check_shlib,$1)
endef

define check_bin
	$(call check_exists,$1)
	$(call check_version,$1,$2,$3)
	$(call check_arch,$1)
	$(call check_output,$1,,$3)
	$(call check_shlib,$1)
endef

ifdef IS_DARWIN
test : ARCH_STRING := $(ARCH)
else ifeq (i386,$(ARCH:i686=i386))
test : ARCH_STRING := 80386
else ifeq (amd64,$(ARCH:x86_64=amd64))
test : ARCH_STRING := x86-64
endif
test :
	$(if $(ARCH_STRING),,@echo Detecting 'ARCH $(ARCH) for OS $(OS) undefined'; false)
	$(call check_bin,advpng,--version 2>&1,$(ADVANCECOMP_VER))
	$(call check_bin,gifsicle,--version,$(GIFSICLE_VER))
	$(call check_bin,jhead,-V,$(JHEAD_VER))
	$(call check_bin,jpeg-recompress,--version,$(JPEGARCHIVE_VER))
	$(call check_bin,jpegoptim,--version,$(JPEGOPTIM_VER))
	$(call check_bin,jpegtran,-v - 2>&1,$(LIBJPEG_VER))
	$(call check_lib,libjpeg$(DLEXT))
	$(call check_lib,libpng$(DLEXT))
	$(call check_lib,libz$(DLEXT))
	$(call check_bin,optipng,--version,$(OPTIPNG_VER))
	$(call check_bin,pngcrush,-version 2>&1,$(PNGCRUSH_VER))
	$(call check_bin,pngquant,--help,$(PNGQUANT_VER))
.PHONY : test

livecheck :; @script/livecheck
.PHONY : livecheck

update-versions :
	script/livecheck --update
	make checksum-update
.PHONY : update-versions

# ====== CLEAN ======

clean :
	rm -rf $(BUILD_DIR)
	rm -rf $(OUTPUT_DIR)
.PHONY : clean

clean-all :
	rm -rf $(BUILD_ROOT_DIR)
	rm -rf $(OUTPUT_ROOT_DIR)
.PHONY : clean-all

clobber : clean-all
	rm -rf $(DL_DIR)
.PHONY : clobber

# ====== BUILD HELPERS ======

# $1 - name of product
# $2 - list of dependency products
define depend-build
# depend this product on every specified product
$($1_EXTRACTED) : $$(filter-out $($1_EXTRACTED),$(foreach dep,$2,$$($(dep)_EXTRACTED)))
$($1_TARGET) : $(foreach dep,$2,$$($(dep)_TARGET))
# add dependent product dir to CPATH, LIBRARY_PATH and PKG_CONFIG_PATH
$($1_TARGET) : export CPATH := $(subst $(eval) ,:,$(foreach dep,$2,$$($(dep)_DIR)))
$($1_TARGET) : export LIBRARY_PATH := $$(CPATH)
$($1_TARGET) : export PKG_CONFIG_PATH := $$(CPATH)
endef

# $1 - name of product
# $2 - list of dependency products
define depend
$(call depend-build,$1,$2)
# depend output of this product on output of every specified product
$$($1_DESTINATION) : $(foreach dep,$2,$$($(dep)_DESTINATION))
endef

pkgconfig_pwd = perl -pi -e 's/(?<=dir=).*/$$ENV{PWD}/'

libtool_target_soname = perl -pi -e 's/(?<=soname_spec=)".*"/"$(@F)"/ ; s/(?<=library_names_spec=)".*"/"\\\$$libname\\\$$shared_ext"/' -- libtool

ifdef IS_DARWIN
chrpath_origin =
else ifdef IS_OPENBSD
chrpath_origin = perl -pi -e 's/XORIGIN/\$$ORIGIN/' -- $1
else
chrpath_origin = chrpath -r '$$ORIGIN' $1
endif

ifdef IS_LINUX
XORIGIN := -Wl,-rpath,XORIGIN
else ifdef IS_BSD
XORIGIN := -Wl,-rpath,XORIGIN -Wl,-z,origin
else
XORIGIN :=
endif

# ====== ENV ======

ifdef IS_DARWIN
export CC := clang
export CXX := clang++
else
export CC := gcc
export CXX := g++
endif

GCC_FLAGS := -O3
STATIC_LIBGCC := $(shell if $(CC) -v 2>&1 | fgrep -q gcc; then echo -static-libgcc; fi)

export CFLAGS = $(GCC_FLAGS)
export CXXFLAGS = $(GCC_FLAGS)
export CPPFLAGS = $(GCC_FLAGS)
export LDFLAGS = $(GCC_FLAGS)

ifdef IS_DARWIN
export MACOSX_DEPLOYMENT_TARGET := 10.7
GCC_FLAGS += -arch $(ARCH)
CXXFLAGS += -stdlib=libc++
endif

ifdef IS_BSD
autotool_version = $(shell printf '%s\n' /usr/local/bin/$1-* | egrep -o '[0-9][^-]+$$' | tail -n 1)
export AUTOCONF_VERSION := $(call autotool_version,autoconf)
export AUTOMAKE_VERSION := $(call autotool_version,automake)
endif

# ====== BUILD TARGETS ======

## advpng
$(eval $(call depend,ADVPNG,LIBZ))
$(ADVPNG_TARGET) :
	cd $(DIR) && ./configure LDFLAGS="$(XORIGIN)"
	cd $(DIR) && $(MAKE) advpng
	$(call chrpath_origin,$@)

## gifsicle
$(GIFSICLE_TARGET) :
	cd $(DIR) && ./configure
	cd $(DIR) && $(MAKE) gifsicle

## jhead
$(JHEAD_TARGET) :
	cd $(DIR) && $(MAKE) jhead CC="$(CC) $(CFLAGS)"

## jpeg-recompress
$(eval $(call depend-build,JPEG-RECOMPRESS,LIBMOZJPEG))
$(JPEG-RECOMPRESS_TARGET) :
	cd $(DIR) && $(MAKE) jpeg-recompress CC="$(CC) $(CFLAGS)" LIBJPEG=$(LIBMOZJPEG_TARGET) \
		MAKE=$(MAKE) # fix for bsd in jpeg-archive-2.1.1

## jpegoptim
$(eval $(call depend,JPEGOPTIM,LIBJPEG))
$(JPEGOPTIM_TARGET) :
	cd $(DIR) && ./configure LDFLAGS="$(XORIGIN)" --host $(HOST)
	cd $(DIR) && $(MAKE) jpegoptim
	$(call chrpath_origin,$@)

## jpegtran
$(eval $(call depend,JPEGTRAN,LIBJPEG))
$(JPEGTRAN_TARGET) :
	cd $(DIR) && $(MAKE) jpegtran LDFLAGS="$(XORIGIN)"
	$(call chrpath_origin,$(JPEGTRAN_TARGET))

## libjpeg
$(LIBJPEG_TARGET) :
	cd $(DIR) && ./configure CC="$(CC) $(CFLAGS)"
	cd $(DIR) && $(libtool_target_soname)
ifdef IS_DARWIN
	cd $(DIR) && $(MAKE) libjpeg.la LDFLAGS="-Wl,-install_name,@loader_path/$(@F)"
else
	cd $(DIR) && $(MAKE) libjpeg.la
endif
	cd $(@D) && $(ln_s) .libs/libjpeg$(DLEXT) .

## libmozjpeg
$(LIBMOZJPEG_TARGET) :
	cd $(DIR) && autoreconf -fiv
	cd $(DIR) && ./configure --host $(HOST)
	cd $(DIR)/simd && $(MAKE)
	cd $(DIR) && $(MAKE) libjpeg.la
	cd $(DIR) && $(ln_s) .libs/libjpeg.a .

## libpng
$(eval $(call depend,LIBPNG,LIBZ))
$(LIBPNG_TARGET) :
	cd $(DIR) && ./configure CC="$(CC) $(CFLAGS)"
	cd $(DIR) && $(pkgconfig_pwd) -- *.pc
	cd $(DIR) && perl -pi -e 's/(?<=lpng)\d+//g' -- *.pc # %MAJOR%%MINOR% suffix
	cd $(DIR) && $(libtool_target_soname)
ifdef IS_DARWIN
	cd $(DIR) && $(MAKE) libpng16.la LDFLAGS="-Wl,-install_name,@loader_path/$(@F)"
else
	cd $(DIR) && $(MAKE) libpng16.la LDFLAGS="$(XORIGIN)"
endif
	cd $(DIR) && $(ln_s) .libs/libpng16$(DLEXT) libpng$(DLEXT)
	$(call chrpath_origin,$@)

## libz
ifdef IS_DARWIN
$(LIBZ_TARGET) : export LDSHARED = $(CC) -dynamiclib -install_name @loader_path/$(@F) -compatibility_version 1 -current_version $(LIBZ_VER)
else
$(LIBZ_TARGET) : export LDSHARED = $(CC) -shared -Wl,-soname,$(@F),--version-script,zlib.map
endif
$(LIBZ_TARGET) :
	cd $(DIR) && ./configure
	cd $(DIR) && $(pkgconfig_pwd) -- *.pc
	cd $(DIR) && $(MAKE) placebo

## optipng
$(eval $(call depend,OPTIPNG,LIBPNG LIBZ))
$(OPTIPNG_TARGET) :
	cd $(DIR) && ./configure -with-system-libs
	cd $(DIR) && $(MAKE) all LDFLAGS="$(XORIGIN) $(LDFLAGS)"
	$(call chrpath_origin,$@)

## pngcrush
$(eval $(call depend,PNGCRUSH,LIBPNG LIBZ))
$(PNGCRUSH_TARGET) :
	cd $(DIR) && rm -f png.h pngconf.h
	cd $(DIR) && $(MAKE) pngcrush \
		CC="$(CC)" \
		LD="$(CC)" \
		LIBS="-lpng -lz -lm" \
		CFLAGS="$(CFLAGS)" \
		CPPFLAGS="$(CPPFLAGS)" \
		LDFLAGS="$(XORIGIN) $(LDFLAGS)"
	$(call chrpath_origin,$@)

## pngquant
$(eval $(call depend,PNGQUANT,LIBPNG LIBZ))
$(PNGQUANT_TARGET) :
	cd $(DIR) && ./configure --without-cocoa --without-lcms2 --extra-ldflags="$(XORIGIN) $(STATIC_LIBGCC)"
	cd $(DIR) && $(MAKE) pngquant
	$(call chrpath_origin,$@)
