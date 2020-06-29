FROM alpine

RUN apk update && \
  apk add --no-cache openssl && \
  apk add --no-cache ncurses && \
  apk add --no-cache tree && \
  apk add --no-cache --upgrade bash && \
  rm -rf /var/cache/apk/*

RUN mkdir /cert
WORKDIR /cert
COPY . /cert
CMD tail -f /etc/hosts