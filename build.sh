#!/bin/bash -e

# Clean up
rm -f configure compile
autoreconf --install --force
rm -rf build
mkdir build

CFLAGS="-O3 --target=wasm32-unknown-unknown-wasm -nostdlib -Wl,--no-entry --sysroot=/musl-sysroot"

function docker_run {
  docker run \
    --user 1000:1000 \
    --volume $(pwd):/c \
    --workdir /c \
    --env CFLAGS="$CFLAGS" \
    --interactive \
    --tty \
    --rm \
    wehlutyk/wasm-compiler:0.3.0 \
    bash -c "$1"
}

# Configure, make and install
docker_run './configure --prefix=/c/build --without-threads --without-python --host=wasm32'
docker_run make
docker_run 'make install'

# Then fix the libxml2.a archive
rm build/lib/libxml2.a
docker_run '$AR rcsv build/lib/libxml2.a *.o'
