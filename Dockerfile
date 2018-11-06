# Official Python base image is needed or some applications will segfault.
FROM python:2.7-alpine

# PyInstaller needs zlib-dev, gcc, libc-dev, and musl-dev
RUN apk --update --no-cache add \
    zlib-dev \
    musl-dev \
    libc-dev \
    gcc \
    g++ \
    make \
    git \
    pwgen \
    libffi-dev \
    openssl-dev \
    xz-dev \
    && pip install --upgrade pip

# Install pycrypto so --key can be used with PyInstaller
RUN pip install \
    pycrypto

ARG PYINSTALLER_TAG=v3.4

# Build bootloader for alpine
RUN git clone --depth 1 --single-branch --branch $PYINSTALLER_TAG https://github.com/pyinstaller/pyinstaller.git /tmp/pyinstaller \
    && cd /tmp/pyinstaller/bootloader \
    && python ./waf configure --no-lsb all \
    && pip install .. \
    && rm -Rf /tmp/pyinstaller

# Install statics
RUN pip install backports.lzma patchelf-wrapper staticx

VOLUME /src
WORKDIR /src

ADD ./bin /pyinstaller
RUN chmod a+x /pyinstaller/*

ENTRYPOINT ["/pyinstaller/pyinstaller.sh"]
