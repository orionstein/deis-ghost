FROM tatsushid/tinycore:6.3-x86_64

# Instructions are run with 'tc' user

RUN tce-load -wic gnupg curl curl-dev expat2 \
    && rm -rf /tmp/tce/optional/*

# verify gpg and sha256: http://nodejs.org/dist/v0.10.30/SHASUMS256.txt.asc
# gpg: aka "Timothy J Fontaine (Work) <tj.fontaine@joyent.com>"
# gpg: aka "Julien Gilli <jgilli@fastmail.fm>"
RUN sudo gpg2 --keyserver pool.sks-keyservers.net --recv-keys 7937DFD2AB06298B2293C3187D33FF9D0246406D 114F43EE0176B71C7BC219DD50A3051F888C628D

ENV NODE_VERSION 0.12.4
ENV NPM_VERSION 2.10.1

ADD config.js /tmp/config.js

RUN tce-load -wic coreutils git unzip wget \
        binutils \
        file \
    && cd /tmp \
    && curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v${NODE_VERSION}-linux-x64.tar.gz" \
    && curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && sudo gpg2 --verify SHASUMS256.txt.asc \
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
    && sudo npm cache clear 

RUN cd /tmp \
    && sudo mkdir /ghost \
    && wget https://ghost.org/zip/ghost-latest.zip \
    && sudo unzip ghost-latest.zip -d /ghost \
    && rm -f ghost-latest.zip \
    && cd /ghost \
    && sudo npm install --production

USER root

RUN sudo su && sed 's/127.0.0.1/0.0.0.0/' /tmp/config.js > /ghost/config.js \
    && sudo adduser ghost --disabled-password --home /ghost \
    && cd /ghost/content/themes \
    && git clone https://github.com/epistrephein/Steam.git

# Add files.
ADD start.bash /ghost-start

# Set environment variables.
ENV NODE_ENV production

ADD http://etcd.orionfree.com:4001/v2/keys/announce/services/postgresql5432 /ghost/dbetcd.json

VOLUME ["/data", "/ghost-override"]

# Define working directory.
WORKDIR /ghost

# Define default command.
CMD ["/bin/sh", "/ghost-start"]

EXPOSE 2368
