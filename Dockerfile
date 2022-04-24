ARG BASEIMAGE=ghcr.io/janderssonse/ort-ci
FROM $BASEIMAGE

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
