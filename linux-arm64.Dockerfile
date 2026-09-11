# syntax=docker/dockerfile:1
# check=skip=InvalidDefaultArgInFrom
ARG UPSTREAM_IMAGE
ARG UPSTREAM_TAG_SHA
ARG UPSTREAM_DIGEST_ARM64

FROM ${UPSTREAM_IMAGE}@${UPSTREAM_DIGEST_ARM64}
EXPOSE 3000 8080
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} FLOOD_AUTH="false" WEBUI_PORTS="8080/tcp,3000/tcp" LIBTORRENT="v2"

RUN ln -s "${CONFIG_DIR}" "${APP_DIR}/qBittorrent"

ARG VERSION_LIB1
ARG VERSION_LIB2
RUN curl -fsSL "https://github.com/userdocs/qbittorrent-nox-static/releases/download/${VERSION_LIB1%%/*}/aarch64-qbittorrent-nox" > "${APP_DIR}/qbittorrent-nox-lib1" && \
    echo "f99d0f9eb15a96d712f52362794276796fc693873be502b45fdbc777e3b17d2c  ${APP_DIR}/qbittorrent-nox-lib1" | sha256sum -c - && \
    chmod 755 "${APP_DIR}/qbittorrent-nox-lib1" && \
    curl -fsSL "https://github.com/userdocs/qbittorrent-nox-static/releases/download/${VERSION_LIB2%%/*}/aarch64-qbittorrent-nox" > "${APP_DIR}/qbittorrent-nox-lib2" && \
    echo "de4239e0c8683e26b970c25e1fe27fb6336635300553f8f0bda2d60299f60ed1  ${APP_DIR}/qbittorrent-nox-lib2" | sha256sum -c - && \
    chmod 755 "${APP_DIR}/qbittorrent-nox-lib2"

ARG VERSION_FLOOD
RUN curl -fsSL "https://nightly.link/jesec/flood/actions/runs/${VERSION_FLOOD}/pkg-binaries.zip" > /tmp/flood.zip && \
    echo "dc347a2e5604b6283d5455104d3aacc8bf98a7f3e14d51058de7fb4ea03a444c  /tmp/flood.zip" | sha256sum -c - && \
    unzip -qo /tmp/flood.zip flood-linux-arm64 -d /tmp && \
    echo "a692f82cb12c5d989f72a93dbeb33324a425ff4fdd12e4fa5b28cf711121fc1d  /tmp/flood-linux-arm64" | sha256sum -c - && \
    mv /tmp/flood-linux-arm64 "${APP_DIR}/flood" && \
    chmod 755 "${APP_DIR}/flood" && \
    rm /tmp/flood.zip

COPY root/ /
RUN find /etc/s6-overlay/s6-rc.d -name "run*" -execdir chmod +x {} +
