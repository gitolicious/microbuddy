# syntax=docker/dockerfile:1.6

FROM zyclonite/zerotier

RUN <<EOF
    apk update
    apk add --no-cache \
        openssh-server \
        rsync
EOF

COPY ./config/ssh/sshd_config /etc/ssh/sshd_config

COPY entrypoint.sh .

ENTRYPOINT [ "/entrypoint.sh" ]
