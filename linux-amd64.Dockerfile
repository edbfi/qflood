# syntax=docker/dockerfile:1
# check=skip=InvalidDefaultArgInFrom
ARG UPSTREAM_IMAGE
ARG UPSTREAM_TAG_SHA
ARG UPSTREAM_DIGEST_AMD64

FROM ${UPSTREAM_IMAGE}@${UPSTREAM_DIGEST_AMD64}
EXPOSE 3000 8080
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} FLOOD_AUTH="false" WEBUI_PORTS="8080/tcp,3000/tcp" LIBTORRENT="v2"

RUN ln -s "${CONFIG_DIR}" "${APP_DIR}/qBittorrent"

ARG VERSION_LIB1
ARG VERSION_LIB2
RUN curl -fsSL "https://github.com/userdocs/qbittorrent-nox-static/releases/download/${VERSION_LIB1%%/*}/x86_64-qbittorrent-nox" > "${APP_DIR}/qbittorrent-nox-lib1" && \
    echo "0546794e32f933560df383c0d11936c921a50f9b5d32a9bcd283481aa695750e  ${APP_DIR}/qbittorrent-nox-lib1" | sha256sum -c - && \
    chmod 755 "${APP_DIR}/qbittorrent-nox-lib1" && \
    curl -fsSL "https://github.com/userdocs/qbittorrent-nox-static/releases/download/${VERSION_LIB2%%/*}/x86_64-qbittorrent-nox" > "${APP_DIR}/qbittorrent-nox-lib2" && \
    echo "c1839caf9b7dbddee09e9a4394bb5b17dc70ecd7c3a9b45e84331d5a1389a645  ${APP_DIR}/qbittorrent-nox-lib2" | sha256sum -c - && \
    chmod 755 "${APP_DIR}/qbittorrent-nox-lib2"

ARG VERSION_FLOOD
RUN curl -fsSL "https://github.com/jesec/flood/releases/download/v${VERSION_FLOOD}/flood-linux-x64" > "${APP_DIR}/flood" && \
    echo "c979f1fd6cf309d143c2c7e9e13ae470f880df72a38f96f4bb4f813175c4ecee  ${APP_DIR}/flood" | sha256sum -c - && \
    chmod 755 "${APP_DIR}/flood"

COPY root/ /
RUN find /etc/s6-overlay/s6-rc.d -name "run*" -execdir chmod +x {} +
