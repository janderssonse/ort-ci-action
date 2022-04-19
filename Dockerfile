ARG BASEIMAGE=ghcr.io/janderssonse/ort-ci
FROM $BASEIMAGE

COPY src/ort-ci-main.sh /opt/ort/ort-ci-main.sh
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
