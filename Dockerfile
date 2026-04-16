FROM alpine:3.23.4

RUN apk add --no-cache openssh-client bash

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]