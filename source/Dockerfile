# syntax=docker/dockerfile:1.6

FROM zyclonite/zerotier

RUN <<EOF
    apk update
    apk add --no-cache   \
        gocryptfs \
        openssh-client \
        rsync
EOF

COPY scripts/ .

COPY entrypoint.sh .

ENTRYPOINT [ "/entrypoint.sh" ]
