ARG PJSUA_VER=2.16
ARG TS3_VER=3.6.2
FROM debian:bookworm-slim AS builder

ARG MAKEFLAGS
ARG PJSUA_VER
ARG TS3_VER

# Set up output structure, install needed headers
RUN apt-get update \
 && mkdir -p /output/usr/bin/ /output/opt/ \
 && apt-get install -y --no-install-recommends build-essential curl file ca-certificates libasound2-dev

# Build pjsua & copy the binary we need
WORKDIR /tmp/pjsua

RUN curl -sSL https://github.com/pjsip/pjproject/archive/refs/tags/$PJSUA_VER.tar.gz | tar xz --strip-components=1 \
 && ./configure \
 && make dep && make \
 && cp pjsip-apps/bin/pjsua-* /output/usr/bin/pjsua

# Download & Extract the Teamspeak Client
WORKDIR /tmp/teamspeak

RUN curl -sSL -o /tmp/teamspeak.run https://files.teamspeak-services.com/releases/client/$TS3_VER/TeamSpeak3-Client-linux_amd64-$TS3_VER.run \
 && chmod +x /tmp/teamspeak.run \
 && /tmp/teamspeak.run --nochown --tar xf \
 && cp -r /tmp/teamspeak /output/opt/teamspeak

# Strip all unneeded symbols for optimum size
RUN find /output -exec sh -c 'file "{}" | grep -q ELF && strip --strip-debug "{}"' \;

#=========================

FROM debian:bookworm-slim

ARG PJSUA_VER
ARG TS3_VER

LABEL maintainer="Adam Dodman <hello@dodman.co.uk>" \
      org.label-schema.vendor="Adam-Ant" \
      org.label-schema.name="DialABot" \
      org.label-schema.url="https://github.com/Adam-Ant/DialABot" \
      org.label-schema.description="A VOIP to Teamspeak3 bot bridge" \
      org.label-schema.version="1.0" \
      io.spritsail.version.pjsua=${PJSUA_VER} \
      io.spritsail.version.teamspeak=${TS3_VER}


RUN apt-get update -qy \
 && apt-get install -qy --no-install-recommends pulseaudio libasound2 xvfb x11vnc xauth dbus tini \
        # Teamspeak required libraries
        libnss3 libxcomposite1 libxcursor1 libpci3 libxslt1.1 libegl1 libxkbcommon0 libevent-2.1-7 libatomic1 \
        libxcb-xinerama0 libxcb-xinput0 libxcb-cursor0 libxcb-icccm4 libxcb-keysyms1 libxcb-shape0 libxcb-xkb1 libxkbcommon-x11-0 \
 && apt-get clean

COPY --from=builder /output/ /
COPY root/ /

RUN chmod +x /usr/bin/*

ENV DISPLAY=":99"

VOLUME ["/config"]

ENTRYPOINT ["tini", "--"]

CMD ["/usr/bin/entrypoint"]
