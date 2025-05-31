FROM alpine:3.22.0

RUN apk add --no-cache openssh-client bash

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]