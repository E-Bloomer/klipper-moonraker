FROM ghcr.io/linuxserver/baseimage-alpine:3.21

ARG INSTALL_DY_MAC=true
ARG VENV_PATH="/lsiopy"
ARG KLIPPER_VENV_DIR="${VENV_PATH}/klippy-env"
ARG MOONRAKER_VENV_DIR="${VENV_PATH}/moonraker-env"

ENV MOONRAKER_DATA_PATH="/config/printer_data" \
    DEBIAN_FRONTEND="noninteractive" \
    TMPDIR="/run/klipper-temp" \ 
    KLIPPER_VENV_DIR="${KLIPPER_VENV_DIR}" \
    MOONRAKER_VENV_DIR="${MOONRAKER_VENV_DIR}" 
    
COPY config/ /defaults

RUN \
    echo "**** install build dependencies ****" && \
    apk add --no-cache --virtual .build-deps \
        build-base \
        python3-dev \
        libffi-dev && \
    apk add --no-cache \
        git \
        py3-virtualenv \
        jpeg-dev \
        openjpeg-dev \
        libsodium-dev \
        wireless-tools \
        iproute2 && \
    echo "**** create klipper venv ****" && \
    [ ! -d ${KLIPPER_VENV_DIR} ] && \
    python3 -m venv ${KLIPPER_VENV_DIR} && \
    ${KLIPPER_VENV_DIR}/bin/pip install -U pip wheel && \
    echo "**** clone and install klipper ****" && \
    git clone https://github.com/Klipper3d/klipper /app/klipper && \
    cd /app/klipper && \
    ${KLIPPER_VENV_DIR}/bin/pip install -r ./scripts/klippy-requirements.txt && \
    ${KLIPPER_VENV_DIR}/bin/python3 klippy/chelper/__init__.py && \
    ${KLIPPER_VENV_DIR}/bin/python3 -m compileall klippy && \
    echo "**** create moonraker venv ****" && \
    [ ! -d ${MOONRAKER_VENV_DIR} ] && \
    python3 -m venv ${MOONRAKER_VENV_DIR} && \
    echo "**** clone and install moonraker ****" && \
    git clone https://github.com/Arksine/moonraker /app/moonraker && \
    cd /app/moonraker && \
    ${MOONRAKER_VENV_DIR}/bin/pip install -U wheel gpiod && \
    ${MOONRAKER_VENV_DIR}/bin/pip install -r ./scripts/moonraker-requirements.txt && \
    ${MOONRAKER_VENV_DIR}/bin/pip install -r ./scripts/moonraker-speedups.txt && \
    ${MOONRAKER_VENV_DIR}/bin/python3 -m compileall moonraker && \
    if [ "$INSTALL_DY_MAC" = "true" ]; then \
      echo "**** installing dynamic macros ****" && \
      curl -fsSL -o /app/klipper/klippy/extras/dynamicmacros.py \
      "https://raw.githubusercontent.com/3DCoded/DynamicMacros/main/dynamicmacros.py" && \
      mv /defaults/printer_dy.cfg /defaults/printer.cfg && \
      mv /defaults/macros.cfg /defaults/dynamicmacros.cfg; \
    else \
      rm -f /defaults/printer_dy.cfg; \
    fi && \
    echo "**** copying extras folder ****" && \
    cp -r /app/klipper/klippy/extras /defaults/extras && \
    echo "**** cleanup build dependencies ****" && \
    apk del .build-deps && \
    rm -rf /var/cache/apk/* /tmp/* /root/.cache /root/.npm /root/.cargo 

COPY root/ /
COPY config/moonraker.conf /defaults/moonraker.conf

VOLUME /config 

EXPOSE 7125

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s CMD curl -f http://localhost:7125/server/info || exit 1