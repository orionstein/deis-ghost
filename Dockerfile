FROM tatsushid/tinycore:6.3-x86_64

# Instructions are run with 'tc' user

RUN tce-load -wic gnupg curl curl-dev expat2 \
    && rm -rf /tmp/tce/optional/*

ENV NODE_VERSION 4.1.1
ENV NPM_VERSION 3.3.5

ENV LANG C.UTF-8
ENV PYTHON_VERSION 2.7.10
ENV PYTHON_PIP_VERSION 7.0.1

RUN tce-load -wic \
        bzip2-dev \
        curl \
        flex \
        file \
        gcc \
        make \
        linux-3.16.2_api_headers \
        glibc_base-dev \
        openssl-1.0.0-dev \
        gdbm-dev \
        ncurses-dev \
        readline-dev \
        sqlite3-dev \
        zlib_base-dev \
        tk-dev \
        libX11-dev \
        libXss \
        libxft \
        libxft-dev \
        ftgl \
        ftgl-dev \
        xz \
        xorg-proto \
        zlib_base \
        zlib_base-dev \
        zlib \
    && sudo ln -s /usr/local/bin/file /usr/bin/file \
    && cd /tmp \
    && curl -SL "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz \
    && curl -SL "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz.asc" -o python.tar.xz.asc \
    && rm python.tar.xz.asc \
    && tar -xJf python.tar.xz \
    && rm python.tar.xz \
    && cd "/tmp/Python-$PYTHON_VERSION" \
    && ./configure --enable-shared --with-ensurepip=install \
    && make \
    && mkdir tmp_install \
    && make install DESTDIR=tmp_install \
    && for F in `find mp_install | xargs file | grep "executable" | grep ELF | grep "not stripped" | cut -f 1 -d :`; do \
            [ -f $F ] && strip --strip-unneeded $F; \
        done \
    && for F in `find tmp_install | xargs file | grep "shared object" | grep ELF | grep "not stripped" | cut -f 1 -d :`; do \
            [ -f $F ] && if [ ! -w $F ]; then chmod u+w $F && strip -g $F && chmod u-w $F; else strip -g $F; fi \
        done \
    && for F in `find tmp_install | xargs file | grep "current ar archive" | cut -f 1 -d :`; do \
            [ -f $F ] && strip -g $F; \
        done \
    && find tmp_install \( -type f -a -name '*.pyc' -o -name '*.pyo' \) -exec rm -rf '{}' + \
    && find tmp_install \( -type d -a -name test -o -name tests \) | xargs rm -rf \
    && $(cd tmp_install; sudo cp -R . /) \
    && rm -rf "/tmp/Python-$PYTHON_VERSION" \
    && cd /tmp/tce/optional \
    && for PKG in `ls *-dev.tcz`; do \
            echo "Removing $PKG files"; \
            for F in `unsquashfs -l $PKG | grep squashfs-root | sed - 's/squashfs-root//'`; do \
                [ -f $F -o -L $F ] && sudo rm -f $F; \
            done; \
            INSTALLED=$(echo -n $PKG | sed -e s/.tcz//); \
            sudo rm -f /usr/local/tce.installed/$INSTALLED; \
        done \
    && for PKG in binutils.tcz \
                cloog.tcz \
                file.tcz \
                flex.tcz \
                gcc.tcz \
                gcc_libs.tcz \
                linux-3.16.2_api_headers.tcz \
                make.tcz \
                sqlite3-bin.tcz \
                xz.tcz \
                xorg-proto.tcz; do \
            echo "Removing $PKG files"; \
            for F in `unsquashfs -l $PKG | grep squashfs-root | sed -e 's/squashfs-root//'`; do \
                [ -f $F -o -L $F ] && sudo rm -f $F; \
            done; \
            INSTALLED=$(echo -n $PKG | sed -e s/.tcz//); \
            sudo rm -f /usr/local/tce.installed/$INSTALLED; \
        done \
    && sudo rm -f /usr/bin/file \
    && sudo /sbin/ldconfig \
    && rm -rf /tmp/tce/optional/* \
    && curl -SL 'https://bootstrap.pypa.io/get-pip.py' | sudo python2 \
    && sudo pip install --upgrade pip==$PYTHON_PIP_VERSION \
    && sudo find /usr/local \( -type f -a -name '*.pyc' -o -name '*.pyo' \) -exec rm -rf '{}' + \
    && find /usr/local \( -type d -a -name test -o -name tests \) | sudo xargs rm -rf \
    && sudo rm -rf /usr/src/python

ADD config.js /tmp/config.js

RUN tce-load -wic coreutils make git unzip wget \
        binutils \
        file \
    && cd /tmp \
    && curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v${NODE_VERSION}-linux-x64.tar.gz" \
    && curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && grep " node-v${NODE_VERSION}-linux-x64.tar.gz" SHASUMS256.txt.asc | sha256sum -c - \
    && tar -xzf "node-v${NODE_VERSION}-linux-x64.tar.gz" \
    && rm -f "node-v${NODE_VERSION}-linux-x64.tar.gz" SHASUMS256.txt.asc \
    && cd "/tmp/node-v${NODE_VERSION}-linux-x64" \
    && for F in `find . | xargs file | grep "executable" | grep ELF | grep "not stripped" | cut -f 1 -d :`; do \
            [ -f $F ] && strip --strip-unneeded $F; \
        done \
    && sudo cp -R . /usr/local \
    && cd / \
    && sudo ln -s /lib /lib64 \
    && rm -rf "/tmp/node-v${NODE_VERSION}-linux-x64" \
    && cd /tmp/tce/optional \
    && for PKG in acl.tcz \
                libcap.tcz \
                coreutils.tcz \
                binutils.tcz \
                file.tcz; do \
            echo "Removing $PKG files"; \
            for F in `unsquashfs -l $PKG | grep squashfs-root | sed -e 's/squashfs-root//'`; do \
                [ -f $F -o -L $F ] && sudo rm -f $F; \
            done; \
            INSTALLED=$(echo -n $PKG | sed -e s/.tcz//); \
            sudo rm -f /usr/local/tce.installed/$INSTALLED; \
        done \
    && rm -rf /tmp/tce/optional/*

RUN sudo npm install -g npm@"$NPM_VERSION" \
    && sudo npm install -g bower \
    && sudo npm install -g node-gyp \
    && sudo npm install -g sqlite3 \
    && sudo npm install -g grunt-cli \
    && sudo npm install -g grunt \
    && sudo npm cache clear 

RUN sudo git clone git://github.com/tryghost/ghost.git /ghost

COPY offixbuild.patch /ghost/

RUN cd /ghost \
    && sudo git checkout stable \
    && sudo git apply -v offixbuild.patch \
    && sudo npm install \
    && sudo npm install ghost-s3-storage \
    && sudo npm install grunt \
    && sudo mkdir -p /ghost/content/storage/ghost-s3

RUN cd /ghost \
    && sudo grunt init \
    && sudo grunt prod

USER root

RUN sudo su && sed 's/127.0.0.1/0.0.0.0/' /tmp/config.js > /ghost/config.js \
    && sudo adduser ghost --disabled-password --home /ghost \
    && cd /ghost/content/themes \
    && git clone https://github.com/epistrephein/Steam.git

ADD index.js /ghost/content/storage/ghost-s3/

ADD include/* /ghost/content/themes/Steam/
ADD include/partials/* /ghost/content/themes/Steam/partials/
ADD include/assets/* /ghost/content/themes/Steam/assets/

# Add files.
ADD start.bash /ghost-start

# Set environment variables.
ENV NODE_ENV production

VOLUME ["/data", "/ghost-override"]

# Define working directory.
WORKDIR /ghost

# Define default command.
CMD ["/bin/sh", "/ghost-start"]

EXPOSE 2368
