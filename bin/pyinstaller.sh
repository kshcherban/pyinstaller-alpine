#!/bin/sh
# Simple wrapper around pyinstaller

set -ex

# Generate a random key for encryption
random_key=$(pwgen -s 16 1)
pyinstaller_args="${@/--random-key/--key $random_key}"

# Use the hacked ldd to fix libc.musl-x86_64.so.1 location
PATH="/pyinstaller:$PATH"
COMPILE_STATIC="${COMPILE_STATIC:-true}"

if [ -f requirements.txt ]; then
    pip install -r requirements.txt
elif [ -f setup.py ]; then
    pip install .
fi

# Exclude pycrypto and PyInstaller from built packages
pyinstaller \
    -n dynamic \
    --exclude-module pycrypto \
    --exclude-module PyInstaller \
    ${pyinstaller_args}

if [ "$COMPILE_STATIC" = "true" ]; then
    staticx dist/dynamic dist/static
fi
