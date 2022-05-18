FROM golang:1-alpine3.15 AS builder

RUN apk add --no-cache git ca-certificates build-base su-exec olm-dev

COPY . /build
WORKDIR /build
RUN go build -o /usr/bin/mautrix-whatsapp

RUN apk add git

FROM alpine:3.15

ENV UID=1337 \
    GID=1337

# We KN removed jq to build it from scratch

RUN git clone https://github.com/stedolan/jq.git && cd jq && autoreconf -i && ./configure --disable-maintainer-mode && make && make install


RUN apk add --no-cache ffmpeg su-exec ca-certificates olm bash yq curl

COPY --from=builder /usr/bin/mautrix-whatsapp /usr/bin/mautrix-whatsapp
COPY --from=builder /build/example-config.yaml /opt/mautrix-whatsapp/example-config.yaml
COPY --from=builder /build/docker-run.sh /docker-run.sh


VOLUME /data

CMD ["/docker-run.sh"]
