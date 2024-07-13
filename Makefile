all :

# ====== VERSIONS ======

ADVANCECOMP_VER := 2.6
GIFSICLE_VER := 1.95
JHEAD_VER := 3.04
JPEGARCHIVE_VER := 2.2.0
JPEGOPTIM_VER := 1.5.5
LIBJPEG_VER := 9f
LIBLCMS_VER := 2.16
LIBMOZJPEG_VER := 4.1.5
LIBPNG_VER := 1.6.43
LIBZ_VER := 1.2.11
OPTIPNG_VER := 0.7.8
OXIPNG_VER := 9.1.2
PNGCRUSH_VER := 1.8.13
PNGOUT_VER := 20200115
PNGOUT_LINUX_VER := $(PNGOUT_VER)
PNGOUT_LINUX_STATIC_VER := $(PNGOUT_VER)
PNGOUT_DARWIN_VER := $(PNGOUT_VER)
PNGQUANT_VER := 2.18.0

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
PATCHES_DIR := $(CURDIR)/patches

export CARGO_HOME := $(DL_DIR)/cargo

ANSI_RED=\033[31m
ANSI_GREEN=\033[32m
ANSI_MAGENTA=\033[35m
ANSI_RESET=\033[0m

# ====== HELPERS ======

downcase = $(shell echo $1 | tr A-Z a-z)

tar := $(shell if command -v bsdtar >/dev/null 2>&1; then echo bsdtar; else echo tar; fi)
sha256sum := $(shell if command -v sha256sum >/dev/null 2>&1; then echo sha256sum; elif command -v shasum >/dev/null 2>&1; then echo shasum -a 256; else echo sha256; fi)

# ====== ARCHIVES ======

ARCHIVES :=

# $1 - name of archive
# $2 - extension to use (instead of default tar.gz)
define archive
ARCHIVES += $1
$1_DIR := $(BUILD_DIR)/$(call downcase,$1)
$1_ARC := $(DL_DIR)/$(call downcase,$1)-$($1_VER).$(or $2,tar.gz)
$1_EXTRACTED := $$($1_DIR)/__$$(notdir $$($1_ARC))__
$$($1_EXTRACTED) : $$($1_ARC)
	mkdir -p $(BUILD_DIR)
	rm -rf $$(@D)
	echo "$$($1_SHA256)  $$<" | $(sha256sum) -c
	mkdir $$(@D)
	$(tar) -C $$(@D) --strip-components=1 -xzf $$<
	touch $$(@D)/__$$(notdir $$<)__
endef

# $1 - name of archive
# $2 - url of archive with [VER] for replace with version
# $3 - extension to use
define archive-dl
$(call archive,$1,$3)
# download archive from url
$$($1_ARC) :
	mkdir -p $(DL_DIR)
	test -w $(DL_DIR)
	while ! mkdir $$@.lock 2> /dev/null; do sleep 1; done
	wget -q -O $$@.tmp $(subst [VER],$($1_VER),$(strip $2))
	mv $$@.tmp $$@
	rm -r $$@.lock
endef

$(eval $(call archive-dl,ADVANCECOMP, https://github.com/amadvance/advancecomp/releases/download/v[VER]/advancecomp-[VER].tar.gz))
$(eval $(call archive-dl,GIFSICLE,    https://www.lcdf.org/gifsicle/gifsicle-[VER].tar.gz))
$(eval $(call archive-dl,JHEAD,       https://www.sentex.ca/~mwandel/jhead/jhead-[VER].tar.gz))
$(eval $(call archive-dl,JPEGARCHIVE, https://github.com/danielgtaylor/jpeg-archive/archive/v[VER].tar.gz))
$(eval $(call archive-dl,JPEGOPTIM,   https://github.com/tjko/jpegoptim/archive/v[VER].tar.gz))
$(eval $(call archive-dl,LIBJPEG,     https://www.ijg.org/files/jpegsrc.v[VER].tar.gz))
$(eval $(call archive-dl,LIBLCMS,     https://prdownloads.sourceforge.net/lcms/lcms2-[VER].tar.gz?download))
$(eval $(call archive-dl,LIBMOZJPEG,  https://github.com/mozilla/mozjpeg/archive/v[VER].tar.gz))
$(eval $(call archive-dl,LIBPNG,      https://prdownloads.sourceforge.net/libpng/libpng-[VER].tar.gz?download))
$(eval $(call archive-dl,LIBZ,        https://prdownloads.sourceforge.net/libpng/zlib-[VER].tar.gz?download))
$(eval $(call archive-dl,OPTIPNG,     https://prdownloads.sourceforge.net/optipng/optipng-[VER].tar.gz?download))
$(eval $(call archive-dl,OXIPNG,      https://github.com/shssoichiro/oxipng/archive/refs/tags/v[VER].tar.gz))
$(eval $(call archive-dl,PNGCRUSH,    https://prdownloads.sourceforge.net/pmt/pngcrush-[VER]-nolib.tar.gz?download))
$(eval $(call archive-dl,PNGOUT_LINUX,https://www.jonof.id.au/files/kenutils/pngout-[VER]-linux.tar.gz))
$(eval $(call archive-dl,PNGOUT_LINUX_STATIC,https://www.jonof.id.au/files/kenutils/pngout-[VER]-linux-static.tar.gz))
$(eval $(call archive-dl,PNGOUT_DARWIN,https://www.jonof.id.au/files/kenutils/pngout-[VER]-macos.zip,zip))
$(eval $(call archive-dl,PNGQUANT,    https://pngquant.org/pngquant-[VER]-src.tar.gz))

download : $(foreach archive,$(ARCHIVES),$($(archive)_ARC))
.PHONY : download

download-dependencies : $(OXIPNG_EXTRACTED)
	cd $(OXIPNG_DIR) && cargo fetch --locked
.PHONY : download-dependencies

download-tidy-up :
	rm -f $(filter-out $(foreach archive,$(ARCHIVES),$($(archive)_ARC)),$(wildcard $(DL_DIR)/*.*))
.PHONY : download-tidy-up

checksum : download
	@$(sha256sum) $(foreach archive,$(ARCHIVES),$($(archive)_ARC))
.PHONY : checksum

checksum-verify : download
	@printf '%s  %s\n' $(foreach archive,$(ARCHIVES),$($(archive)_SHA256) $($(archive)_ARC)) | $(sha256sum) -c
.PHONY : checksum-verify

checksum-update : download
	@printf '%s := %s\n' $(foreach archive,$(ARCHIVES),$(archive)_SHA256 $(shell $(sha256sum) $($(archive)_ARC) | cut -d ' ' -f 1)) > checksums.mk
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
$1_ARC := $($(or $2,$1)_ARC)
$1_EXTRACTED := $($(or $2,$1)_EXTRACTED)
$1_TARGET := $$($1_DIR)/$$($1_PATH)
$$($1_TARGET) : DIR := $$($1_DIR)
$$($1_TARGET) : $$($1_EXTRACTED)
endef

# $1 - product name
# $2 - archive name ($1 if empty)
# $3 - basename ($1 if empty)
# $4 - don't strip the target
define target
$(call target-build,$1,$2,$3)
PRODUCTS += $1
$1_DESTINATION := $$(OUTPUT_DIR)/$$($1_BASENAME)
# copy product to output dir
$$($1_DESTINATION) : $$($1_TARGET)
	mkdir -p $(OUTPUT_DIR)
	temppath=`mktemp "$(BUILD_DIR)"/tmp.XXXXXXXXXX` && \
		$(if $4,cp $$< "$$$$temppath",strip $$< -Sx -o "$$$$temppath") && \
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
$(eval $(call target,LIBLCMS,,liblcms2$(DLEXT)))
$(eval $(call target-build,LIBMOZJPEG,,libjpeg.a))
$(eval $(call target,LIBPNG,,libpng$(DLEXT)))
$(eval $(call target,LIBZ,,libz$(DLEXT)))
$(eval $(call target,OPTIPNG,,src/optipng/optipng))
$(eval $(call target,OXIPNG,,target/release/oxipng))
$(eval $(call target,PNGCRUSH))
ifdef IS_DARWIN
$(eval $(call target,PNGOUT,PNGOUT_DARWIN,,NOSTRIP))
else
$(eval $(call target,PNGOUT,PNGOUT_LINUX,,NOSTRIP))
endif
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
		{ printf "%s: $(ANSI_RED)not found$(ANSI_RESET)\n" "$1"; exit 1; }
endef

define check_version
	@$(OUTPUT_DIR)/$1 $2 | fgrep -q "$3" || \
		{ printf "%s: $(ANSI_RED)Expected %s, got %s$(ANSI_RESET)\n" "$1" "$3" "$$($(OUTPUT_DIR)/$1 $2)"; exit 1; }
endef

define check_arch
	@file -b $(OUTPUT_DIR)/$1 | fgrep -q '$(ARCH_STRING)' || \
		{ printf "%s: $(ANSI_RED)Expected %s, got %s$(ANSI_RESET)\n" "$1" "$(ARCH_STRING)" "$$(file -b $(OUTPUT_DIR)/$1)"; exit 1; }
endef

define check_output
	@printf "%s: $(ANSI_GREEN)%s$(ANSI_RESET) / $(ANSI_MAGENTA)%s$(ANSI_RESET)\n" "$1" "$3" "$(ARCH_STRING)"
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
	$(call check_lib,liblcms2$(DLEXT))
	$(call check_lib,libpng$(DLEXT))
	$(call check_lib,libz$(DLEXT))
	$(call check_bin,optipng,--version,$(OPTIPNG_VER))
	$(call check_bin,oxipng,--version,$(OXIPNG_VER))
	$(call check_bin,pngcrush,-version 2>&1,$(PNGCRUSH_VER))
	$(call check_bin,pngout,2>&1 | head -n 1,$(shell perl -mTime::Piece -e 'print Time::Piece->strptime("$(PNGOUT_VER)", "%Y%m%d")->strftime("%b %e %Y")'))
	$(call check_bin,pngquant,--help,$(PNGQUANT_VER))
.PHONY : test

update-versions :
	script/livecheck --update
	make checksum-update
	make download-dependencies
.PHONY : update-versions

# ====== DOCKER ======

DOCKER_IMAGE := ghcr.io/toy/image_optim
DOCKER_TAG := $(shell date +%Y%m%d)
DOCKER_FILE := Dockerfile

docker-build : download
	@docker build \
		--pull \
		$(foreach archive,$(ARCHIVES),--build-arg $(archive)_VER=$($(archive)_VER) --build-arg $(archive)_SHA256=$($(archive)_SHA256)) \
		-t $(DOCKER_IMAGE):latest$(DOCKER_TAG_SUFFIX) \
		-f $(DOCKER_FILE) \
		.
	@docker tag \
		$(DOCKER_IMAGE):latest$(DOCKER_TAG_SUFFIX) \
		$(DOCKER_IMAGE):$(DOCKER_TAG)$(DOCKER_TAG_SUFFIX)
.PHONY : docker-build

docker-test : docker-build
	@docker run \
		--rm \
		$(DOCKER_IMAGE):latest$(DOCKER_TAG_SUFFIX) \
		--info
.PHONY : docker-test

docker-push : docker-test
	@docker push $(DOCKER_IMAGE):latest$(DOCKER_TAG_SUFFIX)
	@docker push $(DOCKER_IMAGE):$(DOCKER_TAG)$(DOCKER_TAG_SUFFIX)
.PHONY : docker-push

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
export MACOSX_DEPLOYMENT_TARGET := 10.9
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
	cd $(DIR) && $(MAKE) jpeg-recompress CC="$(CC) $(CFLAGS) -fcommon" LIBJPEG=$(LIBMOZJPEG_TARGET) \
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
	cd $(DIR) && ln -sf .libs/libjpeg$(DLEXT) .

## liblcms
$(LIBLCMS_TARGET) :
	cd $(DIR) && ./configure
	cd $(DIR) && $(libtool_target_soname)
ifdef IS_DARWIN
	cd $(DIR)/src && make liblcms2.la LDFLAGS="-Wl,-install_name,@loader_path/$(@F)"
else
	cd $(DIR)/src && make liblcms2.la LDFLAGS="$(XORIGIN)"
endif
	cd $(DIR) && ln -sf include/lcms2.h .
	cd $(DIR) && ln -sf src/.libs/liblcms2$(DLEXT) .

## libmozjpeg
$(LIBMOZJPEG_TARGET) :
	cd $(DIR) && cmake -DPNG_SUPPORTED=0 .
	cd $(DIR) && $(MAKE) jpeg-static

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
	cd $(DIR) && ln -sf .libs/libpng16$(DLEXT) libpng$(DLEXT)
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

## oxipng
$(OXIPNG_TARGET) :
	cd $(DIR) && cargo build --release --frozen --offline

## pngcrush
$(eval $(call depend,PNGCRUSH,LIBPNG LIBZ))
$(PNGCRUSH_TARGET) :
	cd $(DIR) && rm -f png.h pngconf.h
	cd $(DIR) && patch < $(PATCHES_DIR)/pngcrush.patch
	cd $(DIR) && $(MAKE) pngcrush \
		CC="$(CC)" \
		LD="$(CC)" \
		LIBS="-lpng -lz -lm" \
		CFLAGS="$(CFLAGS)" \
		CPPFLAGS="$(CPPFLAGS)" \
		LDFLAGS="$(XORIGIN) $(LDFLAGS)"
	$(call chrpath_origin,$@)

## pngout
$(PNGOUT_TARGET) :
ifdef IS_LINUX
	cd $(DIR) && ln -sf $(ARCH:x86_64=amd64)/pngout .
endif
	cd $(DIR) && touch pngout

## pngquant
$(eval $(call depend,PNGQUANT,LIBLCMS LIBPNG LIBZ))
$(PNGQUANT_TARGET) :
	cd $(DIR) && ./configure --without-cocoa --extra-ldflags="$(XORIGIN) $(STATIC_LIBGCC)"
	cd $(DIR) && $(MAKE) pngquant
	$(call chrpath_origin,$@)
