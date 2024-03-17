FROM alpine as base
ENV LD_LIBRARY_PATH=/usr/local/lib
WORKDIR /tmp

FROM base as build
RUN apk add --no-cache build-base cmake nasm bash findutils
COPY script/extract ./
ENV CPATH=/usr/local/include

FROM build as libz
ARG LIBZ_VER
ARG LIBZ_SHA256
COPY download/libz-$LIBZ_VER.tar.gz download/
RUN ./extract libz && \
    cd build/libz && \
    ./configure && \
    make install

FROM libz as libpng
ARG LIBPNG_VER
ARG LIBPNG_SHA256
COPY download/libpng-$LIBPNG_VER.tar.gz download/
RUN ./extract libpng && \
    cd build/libpng && \
    ./configure --with-zlib-prefix=/usr/local && \
    make install

FROM libpng as liblcms
ARG LIBLCMS_VER
ARG LIBLCMS_SHA256
COPY download/liblcms-$LIBLCMS_VER.tar.gz download/
RUN ./extract liblcms && \
    cd build/liblcms && \
    ./configure && \
    make install

FROM build as libjpeg
ARG LIBJPEG_VER
ARG LIBJPEG_SHA256
COPY download/libjpeg-$LIBJPEG_VER.tar.gz download/
RUN ./extract libjpeg && \
    cd build/libjpeg && \
    ./configure && \
    make install

FROM build as libmozjpeg
ARG LIBMOZJPEG_VER
ARG LIBMOZJPEG_SHA256
COPY download/libmozjpeg-$LIBMOZJPEG_VER.tar.gz download/
RUN ./extract libmozjpeg && \
    cd build/libmozjpeg && \
    cmake -DPNG_SUPPORTED=0 . && \
    make install

FROM libpng as advancecomp
ARG ADVANCECOMP_VER
ARG ADVANCECOMP_SHA256
COPY download/advancecomp-$ADVANCECOMP_VER.tar.gz download/
RUN ./extract advancecomp && \
    cd build/advancecomp && \
    ./configure && \
    make install

FROM build as gifsicle
ARG GIFSICLE_VER
ARG GIFSICLE_SHA256
COPY download/gifsicle-$GIFSICLE_VER.tar.gz download/
RUN ./extract gifsicle && \
    cd build/gifsicle && \
    ./configure && \
    make install

FROM build as jhead
ARG JHEAD_VER
ARG JHEAD_SHA256
COPY download/jhead-$JHEAD_VER.tar.gz download/
RUN ./extract jhead && \
    cd build/jhead && \
    make && \
    install -c jhead /usr/local/bin

FROM libmozjpeg as jpegarchive
ARG JPEGARCHIVE_VER
ARG JPEGARCHIVE_SHA256
COPY download/jpegarchive-$JPEGARCHIVE_VER.tar.gz download/
RUN ./extract jpegarchive && \
    cd build/jpegarchive && \
    CFLAGS=-fcommon make install

FROM libjpeg as jpegoptim
ARG JPEGOPTIM_VER
ARG JPEGOPTIM_SHA256
COPY download/jpegoptim-$JPEGOPTIM_VER.tar.gz download/
RUN ./extract jpegoptim && \
    cd build/jpegoptim && \
    ./configure && \
    make install

FROM libpng as optipng
ARG OPTIPNG_VER
ARG OPTIPNG_SHA256
COPY download/optipng-$OPTIPNG_VER.tar.gz download/
RUN ./extract optipng && \
    cd build/optipng && \
    ./configure && \
    make install

FROM rust:1-alpine as oxipng
RUN apk add --no-cache build-base
COPY script/extract ./
ARG OXIPNG_VER
ARG OXIPNG_SHA256
COPY download/oxipng-$OXIPNG_VER.tar.gz download/
RUN ./extract oxipng && \
    cd build/oxipng && \
    cargo build --release && \
    install -c target/release/oxipng /usr/local/bin

FROM libpng as pngcrush
ARG PNGCRUSH_VER
ARG PNGCRUSH_SHA256
COPY download/pngcrush-$PNGCRUSH_VER.tar.gz download/
COPY patches/pngcrush.patch patches/
RUN ./extract pngcrush && \
    cd build/pngcrush && \
    patch < ../../patches/pngcrush.patch && \
    make && \
    install -c pngcrush /usr/local/bin

FROM build as pngout
ARG PNGOUT_LINUX_STATIC_VER
ARG PNGOUT_LINUX_STATIC_SHA256
COPY download/pngout_linux_static-$PNGOUT_LINUX_STATIC_VER.tar.gz download/
RUN ./extract pngout_linux_static && \
    cd build/pngout_linux_static && \
    cp amd64/pngout-static /usr/local/bin/pngout

FROM liblcms as pngquant
ARG PNGQUANT_VER
ARG PNGQUANT_SHA256
COPY download/pngquant-$PNGQUANT_VER.tar.gz download/
RUN ./extract pngquant && \
    cd build/pngquant && \
    make install

# FROM build as [name]
# ARG [NAME]_VER
# ARG [NAME]_SHA256
# COPY download/[name]-$[NAME]_VER.tar.gz download/
# RUN ./extract [name] && \
#     cd build/[name] && \
#     ./configure && \
#     make install

FROM base as image_optim
RUN apk add --no-cache libstdc++ ruby npm perl dumb-init

COPY README.markdown /
COPY acknowledgements /acknowledgements

COPY --from=advancecomp /usr/local/bin/advpng          /usr/local/bin/
COPY --from=gifsicle    /usr/local/bin/gifsicle        /usr/local/bin/
COPY --from=jhead       /usr/local/bin/jhead           /usr/local/bin/
COPY --from=jpegarchive /usr/local/bin/jpeg-recompress /usr/local/bin/
COPY --from=jpegoptim   /usr/local/bin/jpegoptim       /usr/local/bin/
COPY --from=libjpeg     /usr/local/bin/jpegtran        /usr/local/bin/
COPY --from=optipng     /usr/local/bin/optipng         /usr/local/bin/
COPY --from=oxipng      /usr/local/bin/oxipng          /usr/local/bin/
COPY --from=pngcrush    /usr/local/bin/pngcrush        /usr/local/bin/
COPY --from=pngout      /usr/local/bin/pngout          /usr/local/bin/
COPY --from=pngquant    /usr/local/bin/pngquant        /usr/local/bin/

COPY --from=libjpeg     /usr/local/lib/libjpeg.so.9    /usr/local/lib/
COPY --from=libpng      /usr/local/lib/libpng16.so.16  /usr/local/lib/
COPY --from=libz        /usr/local/lib/libz.so.1       /usr/local/lib/
COPY --from=liblcms     /usr/local/lib/liblcms2.so.2   /usr/local/lib/

RUN npm -g install svgo
RUN gem install --no-document image_optim
ENTRYPOINT ["dumb-init", "image_optim"]
CMD ["--help"]
